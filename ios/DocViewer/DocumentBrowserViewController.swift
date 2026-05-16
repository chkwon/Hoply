import UIKit
import UniformTypeIdentifiers

final class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    init() {
        super.init(forOpening: UTType.hwpViewerSelectableDocuments)
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        title = "HWP Viewer"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func openDocument(at url: URL) {
        guard UTType.isHwpViewerReadableDocument(url) else {
            showUnsupportedDocumentAlert(for: url)
            return
        }

        let viewer = DocumentViewController(documentURL: url)
        let navigationController = UINavigationController(rootViewController: viewer)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let url = documentURLs.first else { return }
        openDocument(at: url)
    }

    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        didImportDocumentAt sourceURL: URL,
        toDestinationURL destinationURL: URL
    ) {
        openDocument(at: destinationURL)
    }

    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        failedToImportDocumentAt documentURL: URL,
        error: Error?
    ) {
        let alert = UIAlertController(
            title: "문서를 가져올 수 없습니다",
            message: error?.localizedDescription ?? documentURL.lastPathComponent,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showUnsupportedDocumentAlert(for url: URL) {
        let alert = UIAlertController(
            title: "지원하지 않는 파일입니다",
            message: url.lastPathComponent,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
