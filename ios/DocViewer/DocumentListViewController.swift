import UIKit
import UniformTypeIdentifiers

private struct DocumentListItem {
    let url: URL
    let fileName: String
    let fileExtension: String
    let modificationDate: Date?
    let fileSize: Int64
}

final class DocumentListViewController: UITableViewController, UIDocumentPickerDelegate {
    private var documents: [DocumentListItem] = []
    private let byteFormatter = ByteCountFormatter()
    private let dateFormatter = DateFormatter()

    init() {
        super.init(style: .insetGrouped)
        title = "Hoply"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFormatters()
        configureNavigation()
        configureTable()
        migrateInboxIfNeeded()
        reloadDocuments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDocuments()
    }

    func openDocument(at url: URL) {
        guard UTType.isHwpViewerReadableDocument(url) else {
            showUnsupportedDocumentAlert(for: url)
            return
        }

        let presentViewer = { [weak self] in
            guard let self else { return }
            let viewer = DocumentViewController(documentURL: url)
            let navigationController = UINavigationController(rootViewController: viewer)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
        }

        if let presentedViewController {
            presentedViewController.dismiss(animated: false, completion: presentViewer)
        } else {
            presentViewer()
        }
    }

    private func configureFormatters() {
        byteFormatter.allowedUnits = [.useKB, .useMB]
        byteFormatter.countStyle = .file

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
    }

    private func configureNavigation() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "가져오기",
            image: UIImage(systemName: "folder.badge.plus"),
            primaryAction: UIAction { [weak self] _ in
                self?.presentImporter()
            }
        )
    }

    private func configureTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocumentCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addAction(
            UIAction { [weak self] _ in
                self?.reloadDocuments()
            },
            for: .valueChanged
        )
    }

    private func reloadDocuments() {
        documents = loadDocuments()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        updateEmptyState()
    }

    private func loadDocuments() -> [DocumentListItem] {
        let documentsDirectory = Self.documentsDirectory
        let keys: [URLResourceKey] = [.isRegularFileKey, .contentModificationDateKey, .fileSizeKey]
        guard let enumerator = FileManager.default.enumerator(
            at: documentsDirectory,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return []
        }

        return enumerator
            .compactMap { $0 as? URL }
            .compactMap { url -> DocumentListItem? in
                guard UTType.isHwpViewerReadableDocument(url) else { return nil }
                let resourceValues = try? url.resourceValues(forKeys: Set(keys))
                guard resourceValues?.isRegularFile == true else { return nil }
                return DocumentListItem(
                    url: url,
                    fileName: url.lastPathComponent,
                    fileExtension: url.pathExtension.uppercased(),
                    modificationDate: resourceValues?.contentModificationDate,
                    fileSize: Int64(resourceValues?.fileSize ?? 0)
                )
            }
            .sorted {
                let lhsDate = $0.modificationDate ?? .distantPast
                let rhsDate = $1.modificationDate ?? .distantPast
                if lhsDate == rhsDate {
                    return $0.fileName.localizedStandardCompare($1.fileName) == .orderedAscending
                }
                return lhsDate > rhsDate
            }
    }

    private func updateEmptyState() {
        guard documents.isEmpty else {
            tableView.backgroundView = nil
            return
        }

        let titleLabel = UILabel()
        titleLabel.text = "문서가 없습니다"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = "HWP 또는 HWPX 파일을 가져오세요."
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let importButton = UIButton(type: .system)
        importButton.setTitle("파일 가져오기", for: .normal)
        importButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        importButton.addAction(
            UIAction { [weak self] _ in
                self?.presentImporter()
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel, importButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -60),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor)
        ])
        tableView.backgroundView = container
    }

    private func presentImporter() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: UTType.hwpViewerReadableDocuments,
            asCopy: true
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }
        openInboundDocument(at: sourceURL)
    }

    func openInboundDocument(at sourceURL: URL) {
        guard UTType.isHwpViewerReadableDocument(sourceURL) else {
            showUnsupportedDocumentAlert(for: sourceURL)
            return
        }

        let didStartSecurityScope = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartSecurityScope {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let openURL = try localDocumentURL(for: sourceURL)
            reloadDocuments()
            openDocument(at: openURL)
        } catch {
            showError(title: "문서를 가져올 수 없습니다", message: error.localizedDescription)
        }
    }

    private func localDocumentURL(for sourceURL: URL) throws -> URL {
        let documentsDirectory = Self.documentsDirectory
        let inboxDirectory = documentsDirectory.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(
            at: documentsDirectory,
            withIntermediateDirectories: true
        )

        let sourcePath = sourceURL.standardizedFileURL.path
        let docsPath = documentsDirectory.standardizedFileURL.path
        let inboxPath = inboxDirectory.standardizedFileURL.path

        let isInInbox = sourcePath == inboxPath || sourcePath.hasPrefix(inboxPath + "/")
        let isInDocsTree = sourcePath == docsPath || sourcePath.hasPrefix(docsPath + "/")

        if isInDocsTree && !isInInbox {
            return sourceURL
        }

        let destinationURL = uniqueDestinationURL(for: sourceURL.lastPathComponent)
        if isInInbox {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        } else {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        }
        return destinationURL
    }

    private func migrateInboxIfNeeded() {
        let inboxDirectory = Self.documentsDirectory
            .appendingPathComponent("Inbox", isDirectory: true)
        guard FileManager.default.fileExists(atPath: inboxDirectory.path) else { return }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: inboxDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        for inboxURL in contents {
            guard UTType.isHwpViewerReadableDocument(inboxURL) else { continue }
            let destinationURL = uniqueDestinationURL(for: inboxURL.lastPathComponent)
            try? FileManager.default.moveItem(at: inboxURL, to: destinationURL)
        }
    }

    private func uniqueDestinationURL(for fileName: String) -> URL {
        let documentsDirectory = Self.documentsDirectory
        let sourceURL = URL(fileURLWithPath: fileName)
        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let fileExtension = sourceURL.pathExtension
        var destinationURL = documentsDirectory.appendingPathComponent(fileName, isDirectory: false)
        var suffix = 2

        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let nextName = fileExtension.isEmpty
                ? "\(baseName) \(suffix)"
                : "\(baseName) \(suffix).\(fileExtension)"
            destinationURL = documentsDirectory.appendingPathComponent(nextName, isDirectory: false)
            suffix += 1
        }
        return destinationURL
    }

    private func showUnsupportedDocumentAlert(for url: URL) {
        showError(title: "지원하지 않는 파일입니다", message: url.lastPathComponent)
    }

    private func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documents.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        let document = documents[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = document.fileName
        content.secondaryText = metadataText(for: document)
        content.image = image(for: document)
        content.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDocument(at: documents[indexPath.row].url)
    }

    private func metadataText(for document: DocumentListItem) -> String {
        let dateText = document.modificationDate.map { dateFormatter.string(from: $0) } ?? "-"
        let sizeText = byteFormatter.string(fromByteCount: document.fileSize)
        return "\(document.fileExtension) · \(dateText) · \(sizeText)"
    }

    private func image(for document: DocumentListItem) -> UIImage? {
        switch document.fileExtension.lowercased() {
        case "hwpx":
            return UIImage(systemName: "doc.zipper")
        default:
            return UIImage(systemName: "doc.text")
        }
    }

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
