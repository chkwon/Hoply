import QuickLook
import OSLog
import UIKit
import WebKit

final class PreviewViewController: UIViewController, QLPreviewingController, WKNavigationDelegate, WKScriptMessageHandler {
    private let logger = Logger(subsystem: "com.chkwon.DocViewer", category: "QuickLook")
    private var documentURL: URL?
    private var webView: WKWebView!
    private var schemeHandler: ViewerSchemeHandler?
    private var didStartSecurityScope = false
    private var pendingCompletion: ((Error?) -> Void)?
    private let errorLabel = UILabel()

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "viewer")
        stopSecurityScopedAccess()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("Quick Look preview view loaded")
        view.backgroundColor = .systemGroupedBackground
        configureErrorLabel()
        configureWebView()
        loadViewerIfReady()
    }

    func preparePreviewOfFile(
        at url: URL,
        completionHandler handler: @escaping (Error?) -> Void
    ) {
        logger.info("preparePreviewOfFile: \(url.lastPathComponent, privacy: .public)")
        stopSecurityScopedAccess()
        documentURL = url
        didStartSecurityScope = url.startAccessingSecurityScopedResource()
        logger.info("Security-scoped access started: \(self.didStartSecurityScope, privacy: .public)")
        pendingCompletion = handler
        loadViewerIfReady()
    }

    private func configureErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.textColor = .secondaryLabel
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "viewer")
        configuration.userContentController = userContentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        guard let viewerRoot = Bundle.main.url(forResource: "ViewerBundle", withExtension: nil) else {
            logger.error("ViewerBundle missing in Quick Look extension bundle")
            completePreview(with: PreviewError.missingViewerBundle)
            return
        }
        logger.info("ViewerBundle found for Quick Look preview")

        let handler = ViewerSchemeHandler(resourceRoot: viewerRoot) { [weak self] in
            guard let self, let documentURL = self.documentURL else {
                self?.logger.error("Quick Look document URL missing while serving document payload")
                throw PreviewError.missingDocument
            }
            self.logger.info("Serving document payload: \(documentURL.lastPathComponent, privacy: .public)")
            return DocumentPayload(
                data: try Data(contentsOf: documentURL),
                fileName: documentURL.lastPathComponent
            )
        }
        configuration.setURLSchemeHandler(handler, forURLScheme: "rhwpviewer")
        schemeHandler = handler

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .systemGroupedBackground
        webView.scrollView.backgroundColor = .systemGroupedBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        view.insertSubview(webView, belowSubview: errorLabel)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func loadViewerIfReady() {
        guard isViewLoaded, webView != nil, documentURL != nil else { return }
        logger.info("Loading Quick Look web viewer")
        errorLabel.isHidden = true
        webView.isHidden = false
        webView.load(URLRequest(url: URL(string: "rhwpviewer://app/index.html")!))
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "viewer",
            let body = message.body as? [String: Any],
            let type = body["type"] as? String
        else { return }

        switch type {
        case "loaded":
            let pageCount = body["pageCount"] as? Int ?? 0
            let fileName = body["fileName"] as? String ?? "unknown"
            logger.info("Quick Look render loaded: \(fileName, privacy: .public), pages: \(pageCount, privacy: .public)")
            completePreview(with: nil)
        case "renderError":
            let recoverable = body["recoverable"] as? Bool ?? false
            guard !recoverable else { return }
            let message = body["message"] as? String ?? PreviewError.renderFailed.localizedDescription
            logger.error("Quick Look render failed: \(message, privacy: .public)")
            showError(message)
            completePreview(with: PreviewError.renderMessage(message))
        default:
            break
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logger.error("Quick Look web navigation failed: \(error.localizedDescription, privacy: .public)")
        showError(error.localizedDescription)
        completePreview(with: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logger.error("Quick Look provisional navigation failed: \(error.localizedDescription, privacy: .public)")
        showError(error.localizedDescription)
        completePreview(with: error)
    }

    private func showError(_ message: String) {
        webView?.isHidden = true
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func completePreview(with error: Error?) {
        guard let pendingCompletion else { return }
        self.pendingCompletion = nil
        if let error {
            logger.error("Completing Quick Look preview with error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.info("Completing Quick Look preview successfully")
        }
        pendingCompletion(error)
    }

    private func stopSecurityScopedAccess() {
        if didStartSecurityScope {
            documentURL?.stopAccessingSecurityScopedResource()
        }
        didStartSecurityScope = false
    }
}

private enum PreviewError: LocalizedError {
    case missingDocument
    case missingViewerBundle
    case renderFailed
    case renderMessage(String)

    var errorDescription: String? {
        switch self {
        case .missingDocument:
            return "문서 URL을 받을 수 없습니다."
        case .missingViewerBundle:
            return "Quick Look 뷰어 리소스가 없습니다."
        case .renderFailed:
            return "문서를 미리 볼 수 없습니다."
        case .renderMessage(let message):
            return message
        }
    }
}
