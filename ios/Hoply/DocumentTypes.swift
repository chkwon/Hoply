import UniformTypeIdentifiers

extension UTType {
    static let hwpOwnedDocument = UTType("com.chkwon.hoply.hwp") ?? UTType(exportedAs: "com.chkwon.hoply.hwp", conformingTo: .data)
    static let hwpxOwnedDocument = UTType("com.chkwon.hoply.hwpx") ?? UTType(exportedAs: "com.chkwon.hoply.hwpx", conformingTo: .data)

    static let hwpDocument = UTType("com.hancom.hwp") ?? UTType(importedAs: "com.hancom.hwp", conformingTo: .data)
    static let hwpHancomOfficeDocument = UTType("com.haansoft.hancomofficeviewer.mac.hwp") ?? UTType(importedAs: "com.haansoft.hancomofficeviewer.mac.hwp", conformingTo: .data)
    static let hwpLibreOfficeDocument = UTType("org.libreoffice.hwp-document") ?? UTType(importedAs: "org.libreoffice.hwp-document", conformingTo: .data)
    static let hwpxDocument = UTType("com.hancom.hwpx") ?? UTType(importedAs: "com.hancom.hwpx", conformingTo: .data)
    static let hwpxHancomOfficeDocument = UTType("com.haansoft.hancomofficeviewer.mac.hwpx") ?? UTType(importedAs: "com.haansoft.hancomofficeviewer.mac.hwpx", conformingTo: .data)

    static let hwpViewerSelectableDocuments: [UTType] = [
        .data
    ]

    static let hwpViewerReadableDocuments: [UTType] = [
        .hwpOwnedDocument,
        .hwpxOwnedDocument,
        .hwpDocument,
        .hwpHancomOfficeDocument,
        .hwpLibreOfficeDocument,
        .hwpxDocument,
        .hwpxHancomOfficeDocument
    ]

    static func isHwpViewerReadableDocument(_ url: URL) -> Bool {
        switch url.pathExtension.lowercased() {
        case "hwp", "hwpx":
            return true
        default:
            return false
        }
    }
}
