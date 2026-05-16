import Foundation
import OSLog
import QuickLook
import UIKit
import WebKit

final class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    private let logger = Logger(subsystem: "com.chkwon.Hoply", category: "QuickLook")
    private var activeRenderers: [ObjectIdentifier: QuickLookPDFRenderer] = [:]

    func providePreview(
        for request: QLFilePreviewRequest,
        completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void
    ) {
        let documentURL = request.fileURL
        logger.info("Data-based Quick Look preview requested: \(documentURL.lastPathComponent, privacy: .public)")

        DispatchQueue.main.async {
            let renderer = QuickLookPDFRenderer(documentURL: documentURL, logger: self.logger)
            let rendererID = ObjectIdentifier(renderer)
            self.activeRenderers[rendererID] = renderer

            Task { @MainActor in
                do {
                    let pdfURL = try await renderer.renderPDF()
                    let reply = QLPreviewReply(fileURL: pdfURL)
                    reply.title = documentURL.deletingPathExtension().lastPathComponent
                    self.logger.info("Data-based Quick Look PDF ready: \(pdfURL.lastPathComponent, privacy: .public)")
                    handler(reply, nil)
                } catch {
                    self.logger.error("Data-based Quick Look preview failed: \(error.localizedDescription, privacy: .public)")
                    handler(nil, error)
                }

                self.activeRenderers[rendererID] = nil
            }
        }
    }
}

@MainActor
private final class QuickLookPDFRenderer: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    private let documentURL: URL
    private let logger: Logger
    private var webView: WKWebView?
    private var schemeHandler: ViewerSchemeHandler?
    private var didStartSecurityScope = false
    private var loadContinuation: CheckedContinuation<Void, Error>?
    private var loadTimeout: DispatchWorkItem?

    init(documentURL: URL, logger: Logger) {
        self.documentURL = documentURL
        self.logger = logger
        super.init()
    }

    func renderPDF() async throws -> URL {
        didStartSecurityScope = documentURL.startAccessingSecurityScopedResource()
        logger.info("Quick Look PDF renderer security scope: \(self.didStartSecurityScope, privacy: .public)")
        defer {
            cleanupWebView()
        }

        try configureWebView()
        try await loadViewer()
        let pdfURL = try await makeTemporaryPDF()
        return pdfURL
    }

    private func configureWebView() throws {
        guard let viewerRoot = Bundle.main.url(forResource: "ViewerBundle", withExtension: nil) else {
            throw QuickLookPreviewError.missingViewerBundle
        }

        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "viewer")
        configuration.userContentController = userContentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let handler = ViewerSchemeHandler(resourceRoot: viewerRoot) { [documentURL, logger] in
            logger.info("Serving Quick Look document payload: \(documentURL.lastPathComponent, privacy: .public)")
            return DocumentPayload(
                data: try Data(contentsOf: documentURL),
                fileName: documentURL.lastPathComponent
            )
        }
        configuration.setURLSchemeHandler(handler, forURLScheme: "rhwpviewer")
        schemeHandler = handler

        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 794, height: 1123),
            configuration: configuration
        )
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView = webView
    }

    private func loadViewer() async throws {
        guard let webView else {
            throw QuickLookPreviewError.webViewUnavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            loadContinuation = continuation

            let timeout = DispatchWorkItem { [weak self] in
                self?.finishLoading(with: .failure(QuickLookPreviewError.renderTimedOut))
            }
            loadTimeout = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: timeout)

            logger.info("Loading Quick Look web renderer")
            webView.load(URLRequest(url: URL(string: "rhwpviewer://app/index.html")!))
        }
    }

    private func makeTemporaryPDF() async throws -> URL {
        guard let webView else {
            throw QuickLookPreviewError.webViewUnavailable
        }

        try await prepareViewerForPrint()
        defer {
            webView.evaluateJavaScript("window.RHWPViewer.clearPrintMode()")
        }

        let configuration = WKPDFConfiguration()
        let contentSize = webView.scrollView.contentSize
        let boundsSize = webView.bounds.size
        let pdfSize = CGSize(
            width: max(contentSize.width, boundsSize.width),
            height: max(contentSize.height, boundsSize.height)
        )
        if pdfSize.width > 0, pdfSize.height > 0 {
            configuration.rect = CGRect(origin: .zero, size: pdfSize)
        }

        let data = try await createPDF(configuration: configuration)
        guard !data.isEmpty else {
            throw QuickLookPreviewError.emptyPDF
        }

        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HoplyQuickLook-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let baseName = sanitizedBaseName(documentURL.deletingPathExtension().lastPathComponent)
        let outputURL = directoryURL.appendingPathComponent("\(baseName).pdf")
        try data.write(to: outputURL, options: .atomic)
        return outputURL
    }

    private func prepareViewerForPrint() async throws {
        guard let webView else {
            throw QuickLookPreviewError.webViewUnavailable
        }

        let result = try await evaluateJavaScript("Boolean(window.RHWPViewer.prepareForPrint())")
        guard result as? Bool == true else {
            throw QuickLookPreviewError.printPreparationFailed
        }

        webView.scrollView.setContentOffset(.zero, animated: false)
        webView.setNeedsLayout()
        webView.layoutIfNeeded()
        try await Task.sleep(nanoseconds: 150_000_000)
    }

    private func createPDF(configuration: WKPDFConfiguration) async throws -> Data {
        guard let webView else {
            throw QuickLookPreviewError.webViewUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            webView.createPDF(configuration: configuration) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func evaluateJavaScript(_ script: String) async throws -> Any? {
        guard let webView else {
            throw QuickLookPreviewError.webViewUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "viewer",
            let body = message.body as? [String: Any],
            let type = body["type"] as? String
        else { return }

        switch type {
        case "loaded":
            let fileName = body["fileName"] as? String ?? documentURL.lastPathComponent
            let pageCount = body["pageCount"] as? Int ?? 0
            logger.info("Quick Look web renderer loaded: \(fileName, privacy: .public), pages: \(pageCount, privacy: .public)")
            finishLoading(with: .success(()))
        case "renderError":
            let recoverable = body["recoverable"] as? Bool ?? false
            guard !recoverable else { return }
            let message = body["message"] as? String ?? QuickLookPreviewError.renderFailed.localizedDescription
            logger.error("Quick Look web renderer failed: \(message, privacy: .public)")
            finishLoading(with: .failure(QuickLookPreviewError.renderMessage(message)))
        default:
            break
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logger.error("Quick Look web renderer navigation failed: \(error.localizedDescription, privacy: .public)")
        finishLoading(with: .failure(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logger.error("Quick Look web renderer provisional navigation failed: \(error.localizedDescription, privacy: .public)")
        finishLoading(with: .failure(error))
    }

    private func finishLoading(with result: Result<Void, Error>) {
        loadTimeout?.cancel()
        loadTimeout = nil

        guard let continuation = loadContinuation else { return }
        loadContinuation = nil

        switch result {
        case .success:
            continuation.resume()
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }

    private func cleanupWebView() {
        loadTimeout?.cancel()
        loadTimeout = nil
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "viewer")
        webView?.navigationDelegate = nil
        webView = nil
        schemeHandler = nil
        stopSecurityScopedAccess()
    }

    private func stopSecurityScopedAccess() {
        if didStartSecurityScope {
            documentURL.stopAccessingSecurityScopedResource()
        }
        didStartSecurityScope = false
    }

    private func sanitizedBaseName(_ baseName: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._- "))
        let sanitized = String(baseName.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" })
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return sanitized.isEmpty ? "Hoply-Preview" : sanitized
    }
}

private enum QuickLookPreviewError: LocalizedError {
    case emptyPDF
    case missingViewerBundle
    case printPreparationFailed
    case renderFailed
    case renderMessage(String)
    case renderTimedOut
    case webViewUnavailable

    var errorDescription: String? {
        switch self {
        case .emptyPDF:
            return "빈 PDF가 생성되었습니다."
        case .missingViewerBundle:
            return "Quick Look 뷰어 리소스가 없습니다."
        case .printPreparationFailed:
            return "문서가 아직 Quick Look 미리보기용으로 준비되지 않았습니다."
        case .renderFailed:
            return "문서를 미리 볼 수 없습니다."
        case .renderMessage(let message):
            return message
        case .renderTimedOut:
            return "Quick Look 미리보기 렌더링 시간이 초과되었습니다."
        case .webViewUnavailable:
            return "Quick Look 렌더러를 시작할 수 없습니다."
        }
    }
}
