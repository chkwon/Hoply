import init, { HwpDocument, version as rhwpVersion } from '@rhwp/core';
import wasmUrl from '@rhwp/core/rhwp_bg.wasm?url';
import './styles.css';

type NativeEvent =
  | { type: 'loaded'; pageCount: number; fileName: string; rhwpVersion: string }
  | { type: 'pageChanged'; pageIndex: number }
  | { type: 'renderError'; message: string; recoverable: boolean };

type PageInfo = {
  pageIndex?: number;
  width?: number;
  height?: number;
  sectionIndex?: number;
};

type WebKitBridge = {
  messageHandlers?: {
    viewer?: {
      postMessage: (message: NativeEvent) => void;
    };
  };
};

declare global {
  interface Window {
    RHWPViewer: ViewerApi;
    webkit?: WebKitBridge;
  }

  // rhwp calls this global while computing text layout.
  // eslint-disable-next-line no-var
  var measureTextWidth: (font: string, text: string) => number;
}

interface ViewerApi {
  loadCurrentDocument: () => Promise<void>;
  setZoom: (scale: number) => void;
  renderAllPages: () => boolean;
  prepareForPrint: () => boolean;
  clearPrintMode: () => void;
}

const pagesElement = document.querySelector<HTMLElement>('#pages');
const errorMessageElement = document.querySelector<HTMLElement>('#error-message');

if (!pagesElement || !errorMessageElement) {
  throw new Error('Viewer shell is missing required elements.');
}

const pagesEl = pagesElement;
const errorMessageEl = errorMessageElement;

let measureContext: CanvasRenderingContext2D | null = null;
let lastMeasuredFont = '';

globalThis.measureTextWidth = (font: string, text: string): number => {
  if (!measureContext) {
    measureContext = document.createElement('canvas').getContext('2d');
  }
  if (!measureContext) return text.length * 10;
  if (font !== lastMeasuredFont) {
    measureContext.font = font;
    lastMeasuredFont = font;
  }
  return measureContext.measureText(text).width;
};

const postNative = (event: NativeEvent): void => {
  window.webkit?.messageHandlers?.viewer?.postMessage(event);
};

const setError = (message: string, recoverable = false): void => {
  errorMessageEl.textContent = message;
  document.body.classList.add('has-error');
  postNative({ type: 'renderError', message, recoverable });
};

class RhwpReadOnlyViewer implements ViewerApi {
  private document: HwpDocument | null = null;
  private observer: IntersectionObserver | null = null;
  private pageCount = 0;
  private pageInfos: PageInfo[] = [];
  private renderedPages = new Set<number>();
  private currentPageIndex = -1;
  private userZoom = 1;
  private fitScale = 1;

  constructor() {
    window.addEventListener('resize', () => this.updateFitScale());
    window.addEventListener('orientationchange', () => {
      window.setTimeout(() => this.updateFitScale(), 150);
    });
  }

  async loadCurrentDocument(): Promise<void> {
    try {
      await init({ module_or_path: wasmUrl });

      const response = await fetch('./document/current', { cache: 'no-store' });
      if (!response.ok) {
        throw new Error(`문서 데이터를 읽을 수 없습니다. (${response.status})`);
      }

      const fileName = decodeURIComponent(response.headers.get('X-Document-Name') ?? 'document.hwp');
      const bytes = new Uint8Array(await response.arrayBuffer());
      this.document?.free();
      this.document = new HwpDocument(bytes);
      this.pageCount = this.document.pageCount();
      this.pageInfos = this.collectPageInfo();

      this.buildPlaceholders();
      this.updateFitScale();
      document.body.classList.add('is-loaded');
      document.body.classList.remove('has-error');

      postNative({
        type: 'loaded',
        pageCount: this.pageCount,
        fileName,
        rhwpVersion: rhwpVersion()
      });
    } catch (error) {
      setError(error instanceof Error ? error.message : String(error));
    }
  }

  setZoom(scale: number): void {
    this.userZoom = Number.isFinite(scale) ? Math.min(4, Math.max(0.35, scale)) : 1;
    this.applyDisplaySizes();
  }

  renderAllPages(): boolean {
    if (!this.document) return false;
    for (let index = 0; index < this.pageCount; index += 1) {
      this.renderPage(index);
    }
    return true;
  }

  prepareForPrint(): boolean {
    const rendered = this.renderAllPages();
    if (rendered) {
      document.body.classList.add('print-mode');
    }
    return rendered;
  }

  clearPrintMode(): void {
    document.body.classList.remove('print-mode');
  }

  private collectPageInfo(): PageInfo[] {
    const infos: PageInfo[] = [];
    if (!this.document) return infos;

    for (let index = 0; index < this.pageCount; index += 1) {
      try {
        infos.push(JSON.parse(this.document.getPageInfo(index)) as PageInfo);
      } catch {
        infos.push({ pageIndex: index });
      }
    }
    return infos;
  }

  private buildPlaceholders(): void {
    pagesEl.replaceChildren();
    this.renderedPages.clear();
    this.observer?.disconnect();

    this.observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((entry) => entry.isIntersecting)
          .map((entry) => Number((entry.target as HTMLElement).dataset.pageIndex))
          .filter(Number.isFinite)
          .sort((a, b) => a - b);

        for (const pageIndex of visible) {
          this.renderPage(pageIndex);
        }
        if (visible.length > 0 && visible[0] !== this.currentPageIndex) {
          this.currentPageIndex = visible[0];
          postNative({ type: 'pageChanged', pageIndex: visible[0] });
        }
      },
      { rootMargin: '900px 0px 900px 0px', threshold: 0.05 }
    );

    for (let index = 0; index < this.pageCount; index += 1) {
      const page = document.createElement('article');
      page.className = 'page';
      page.dataset.pageIndex = String(index);
      page.setAttribute('aria-label', `${index + 1} 페이지`);

      const info = this.pageInfos[index];
      if (info?.width) {
        page.style.setProperty('--page-width', `${info.width}px`);
      }
      if (info?.height) {
        page.style.setProperty('--page-height', `${info.height}px`);
      }

      const placeholder = document.createElement('div');
      placeholder.className = 'page-placeholder';
      placeholder.textContent = `${index + 1} / ${this.pageCount}`;
      page.append(placeholder);
      pagesEl.append(page);
      this.observer.observe(page);
    }
  }

  private renderPage(index: number): void {
    if (!this.document || this.renderedPages.has(index)) return;

    const page = pagesEl.querySelector<HTMLElement>(`[data-page-index="${index}"]`);
    if (!page) return;

    try {
      const svg = this.document.renderPageSvg(index);
      page.replaceChildren();
      page.insertAdjacentHTML('afterbegin', svg);
      this.applyPageSizeFromSvg(page);
      this.renderedPages.add(index);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      page.replaceChildren();
      const placeholder = document.createElement('div');
      placeholder.className = 'page-placeholder';
      placeholder.textContent = `${index + 1} 페이지 렌더링 실패`;
      page.append(placeholder);
      postNative({ type: 'renderError', message, recoverable: true });
    }
  }

  private applyPageSizeFromSvg(page: HTMLElement): void {
    const svg = page.querySelector('svg');
    if (!svg) return;

    const viewBox = svg.getAttribute('viewBox');
    if (!viewBox) return;

    const [, , width, height] = viewBox.split(/\s+/).map(Number);
    if (Number.isFinite(width) && width > 0) {
      page.style.setProperty('--page-width', `${width}px`);
      this.applyDisplaySizes();
    }
    if (Number.isFinite(height) && height > 0) {
      page.style.setProperty('--page-height', `${height}px`);
    }
  }

  private updateFitScale(): void {
    const pageWidth = this.pageInfos.find((info) => Number.isFinite(info.width) && (info.width ?? 0) > 0)?.width ?? 794;
    const availableWidth = Math.max(240, window.innerWidth || document.documentElement.clientWidth || 390);
    this.fitScale = Math.min(2.5, Math.max(0.2, availableWidth / pageWidth));
    this.applyDisplaySizes();
  }

  private applyDisplaySizes(): void {
    const pages = pagesEl.querySelectorAll<HTMLElement>('.page');
    for (const page of pages) {
      const index = Number(page.dataset.pageIndex);
      const info = Number.isFinite(index) ? this.pageInfos[index] : undefined;
      const width = this.readPageDimension(page, '--page-width', info?.width, 794);
      const height = this.readPageDimension(page, '--page-height', info?.height, 1123);
      const displayWidth = width * this.fitScale * this.userZoom;
      const displayHeight = height * this.fitScale * this.userZoom;
      page.style.setProperty('--display-width', `${displayWidth}px`);
      page.style.setProperty('--display-height', `${displayHeight}px`);
    }
  }

  private readPageDimension(page: HTMLElement, property: string, value: number | undefined, fallback: number): number {
    if (Number.isFinite(value) && value && value > 0) return value;
    const fromStyle = Number.parseFloat(page.style.getPropertyValue(property));
    return Number.isFinite(fromStyle) && fromStyle > 0 ? fromStyle : fallback;
  }
}

window.RHWPViewer = new RhwpReadOnlyViewer();
void window.RHWPViewer.loadCurrentDocument();
