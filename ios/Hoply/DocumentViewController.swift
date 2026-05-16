import UIKit
import WebKit

final class DocumentViewController: UIViewController, WKScriptMessageHandler {
    private let documentURL: URL
    private var webView: WKWebView!
    private var schemeHandler: ViewerSchemeHandler?
    private var didStartSecurityScope = false
    private var pageCount = 0
    private var currentPageIndex = 0
    private var zoomScale: Double = 1
    private let pageLabel = UILabel()
    private let titleLabel = UILabel()

    init(documentURL: URL) {
        self.documentURL = documentURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "viewer")
        if didStartSecurityScope {
            documentURL.stopAccessingSecurityScopedResource()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = .systemGroupedBackground
        didStartSecurityScope = documentURL.startAccessingSecurityScopedResource()

        configureNavigation()
        configureWebView()
        loadViewer()
    }

    private func configureNavigation() {
        configureBarAppearance()
        configureTitleView()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )

        let shareMenu = UIMenu(children: [
            UIAction(title: "원본 공유", image: UIImage(systemName: "doc")) { [weak self] _ in
                self?.shareOriginal()
            },
            UIAction(title: "PDF 공유", image: UIImage(systemName: "doc.richtext")) { [weak self] _ in
                Task { await self?.sharePDF() }
            }
        ])
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            primaryAction: nil,
            menu: shareMenu
        )
        let printButton = UIBarButtonItem(
            image: UIImage(systemName: "printer"),
            primaryAction: UIAction { [weak self] _ in
                Task { await self?.printDocument() }
            }
        )
        navigationItem.rightBarButtonItems = [shareButton, printButton]

        pageLabel.font = .preferredFont(forTextStyle: .footnote)
        pageLabel.textColor = .secondaryLabel
        pageLabel.textAlignment = .center
        pageLabel.text = "- / -"
        pageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true

        toolbarItems = [
            UIBarButtonItem(image: UIImage(systemName: "minus.magnifyingglass"), style: .plain, target: self, action: #selector(zoomOut)),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(customView: pageLabel),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), style: .plain, target: self, action: #selector(zoomIn))
        ]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.toolbar.isTranslucent = false
        navigationController?.setToolbarHidden(false, animated: false)
    }

    private func configureBarAppearance() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = .systemBackground
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.standardAppearance = navigationAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        navigationController?.navigationBar.compactAppearance = navigationAppearance

        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = .systemBackground
        navigationController?.toolbar.standardAppearance = toolbarAppearance
        navigationController?.toolbar.scrollEdgeAppearance = toolbarAppearance
    }

    private func configureTitleView() {
        let titleContainer = UIView(frame: CGRect(x: 0, y: 0, width: 220, height: 44))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        titleContainer.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor)
        ])
        navigationItem.titleView = titleContainer
        setViewerTitle(documentURL.lastPathComponent)
    }

    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "viewer")
        configuration.userContentController = userContentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        guard let viewerRoot = Bundle.main.url(forResource: "ViewerBundle", withExtension: nil) else {
            showError(title: "뷰어 리소스가 없습니다", message: "먼저 npm run build:viewer를 실행해 주세요.")
            return
        }

        let handler = ViewerSchemeHandler(resourceRoot: viewerRoot) { [weak self] in
            guard let self else { throw CocoaError(.userCancelled) }
            return try self.readDocumentPayload()
        }
        configuration.setURLSchemeHandler(handler, forURLScheme: "rhwpviewer")
        schemeHandler = handler

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .systemGroupedBackground
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.backgroundColor = .systemGroupedBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func loadViewer() {
        guard webView != nil else { return }
        let request = URLRequest(url: URL(string: "rhwpviewer://app/index.html")!)
        webView.load(request)
    }

    private func readDocumentPayload() throws -> DocumentPayload {
        DocumentPayload(data: try Data(contentsOf: documentURL), fileName: documentURL.lastPathComponent)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "viewer",
            let body = message.body as? [String: Any],
            let type = body["type"] as? String
        else { return }

        switch type {
        case "loaded":
            pageCount = body["pageCount"] as? Int ?? 0
            if let fileName = body["fileName"] as? String {
                setViewerTitle(fileName)
            }
            updatePageLabel()
        case "pageChanged":
            currentPageIndex = body["pageIndex"] as? Int ?? currentPageIndex
            updatePageLabel()
        case "renderError":
            let recoverable = body["recoverable"] as? Bool ?? false
            guard !recoverable else { return }
            showError(
                title: "문서를 열 수 없습니다",
                message: body["message"] as? String ?? "알 수 없는 오류가 발생했습니다."
            )
        default:
            break
        }
    }

    private func setViewerTitle(_ fileName: String) {
        title = fileName
        titleLabel.text = fileName
        titleLabel.accessibilityLabel = fileName
    }

    private func updatePageLabel() {
        guard pageCount > 0 else {
            pageLabel.text = "- / -"
            return
        }
        pageLabel.text = "\(min(currentPageIndex + 1, pageCount)) / \(pageCount)"
    }

    @objc private func zoomIn() {
        setZoom(zoomScale + 0.1)
    }

    @objc private func zoomOut() {
        setZoom(zoomScale - 0.1)
    }

    private func setZoom(_ value: Double) {
        zoomScale = min(3, max(0.5, value))
        webView.evaluateJavaScript("window.RHWPViewer.setZoom(\(zoomScale))")
    }

    private func shareOriginal() {
        presentActivity(items: [documentURL], source: navigationItem.rightBarButtonItems?.first)
    }

    @MainActor
    private func sharePDF() async {
        do {
            let pdfURL = try await makeTemporaryPDF()
            presentActivity(items: [pdfURL], source: navigationItem.rightBarButtonItems?.first) {
                try? FileManager.default.removeItem(at: pdfURL)
            }
        } catch {
            showError(title: "PDF를 만들 수 없습니다", message: error.localizedDescription)
        }
    }

    @MainActor
    private func printDocument() async {
        do {
            try await prepareViewerForPrint()
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = documentURL.deletingPathExtension().lastPathComponent
            printController.printInfo = printInfo
            printController.printFormatter = webView.viewPrintFormatter()
            printController.present(animated: true) { [weak self] _, _, _ in
                self?.webView.evaluateJavaScript("window.RHWPViewer.clearPrintMode()")
            }
        } catch {
            showError(title: "프린트 준비 실패", message: error.localizedDescription)
        }
    }

    @MainActor
    private func makeTemporaryPDF() async throws -> URL {
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
        let baseName = documentURL.deletingPathExtension().lastPathComponent
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(baseName)-Hoply.pdf")
        try data.write(to: outputURL, options: .atomic)
        return outputURL
    }

    @MainActor
    private func prepareViewerForPrint() async throws {
        let result = try await evaluateJavaScript("Boolean(window.RHWPViewer.prepareForPrint())")
        guard result as? Bool == true else {
            throw DocumentViewError.printPreparationFailed
        }
        webView.scrollView.setContentOffset(.zero, animated: false)
        webView.setNeedsLayout()
        webView.layoutIfNeeded()
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    @MainActor
    private func evaluateJavaScript(_ script: String) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    @MainActor
    private func createPDF(configuration: WKPDFConfiguration) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
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

    private func presentActivity(
        items: [Any],
        source: UIBarButtonItem?,
        completion: (() -> Void)? = nil
    ) {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.popoverPresentationController?.barButtonItem = source
        activity.completionWithItemsHandler = { _, _, _, _ in completion?() }
        present(activity, animated: true)
    }

    private func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

private enum DocumentViewError: LocalizedError {
    case printPreparationFailed

    var errorDescription: String? {
        switch self {
        case .printPreparationFailed:
            return "문서가 아직 PDF/프린트용으로 준비되지 않았습니다."
        }
    }
}
