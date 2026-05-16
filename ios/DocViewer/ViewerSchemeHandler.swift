import Foundation
import UniformTypeIdentifiers
import WebKit

struct DocumentPayload {
    let data: Data
    let fileName: String
}

final class ViewerSchemeHandler: NSObject, WKURLSchemeHandler {
    private let resourceRoot: URL
    private let documentProvider: () throws -> DocumentPayload

    init(resourceRoot: URL, documentProvider: @escaping () throws -> DocumentPayload) {
        self.resourceRoot = resourceRoot
        self.documentProvider = documentProvider
        super.init()
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(ViewerSchemeError.badURL)
            return
        }

        do {
            if url.host == "app", url.path == "/document/current" {
                let payload = try documentProvider()
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                        "Content-Type": mimeType(forDocumentNamed: payload.fileName),
                        "Cache-Control": "no-store",
                        "X-Document-Name": payload.fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? payload.fileName
                    ]
                )!
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(payload.data)
                urlSchemeTask.didFinish()
                return
            }

            let fileURL = try resourceURL(for: url)
            let data = try Data(contentsOf: fileURL)
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": mimeType(forResource: fileURL),
                    "Cache-Control": "no-cache"
                ]
            )!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }

    private func resourceURL(for url: URL) throws -> URL {
        guard url.host == "app" else {
            throw ViewerSchemeError.badURL
        }

        let requestedPath = url.path == "/" || url.path.isEmpty ? "/index.html" : url.path
        let relativePath = requestedPath.drop(while: { $0 == "/" })
        guard !relativePath.contains("..") else {
            throw ViewerSchemeError.forbidden
        }

        let fileURL = resourceRoot.appendingPathComponent(String(relativePath), isDirectory: false)
        let standardizedRoot = resourceRoot.standardizedFileURL.path
        let standardizedFile = fileURL.standardizedFileURL.path
        guard standardizedFile.hasPrefix(standardizedRoot) else {
            throw ViewerSchemeError.forbidden
        }
        return fileURL
    }

    private func mimeType(forResource url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "html":
            return "text/html; charset=utf-8"
        case "js", "mjs":
            return "text/javascript; charset=utf-8"
        case "css":
            return "text/css; charset=utf-8"
        case "wasm":
            return "application/wasm"
        case "json", "map":
            return "application/json; charset=utf-8"
        case "svg":
            return "image/svg+xml"
        case "png":
            return "image/png"
        case "woff2":
            return "font/woff2"
        default:
            if let type = UTType(filenameExtension: url.pathExtension),
               let mime = type.preferredMIMEType {
                return mime
            }
            return "application/octet-stream"
        }
    }

    private func mimeType(forDocumentNamed fileName: String) -> String {
        switch URL(fileURLWithPath: fileName).pathExtension.lowercased() {
        case "hwp":
            return "application/x-hwp"
        case "hwpx":
            return "application/vnd.hancom.hwpx"
        default:
            return "application/octet-stream"
        }
    }
}

enum ViewerSchemeError: LocalizedError {
    case badURL
    case forbidden

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid viewer resource URL."
        case .forbidden:
            return "Viewer resource path is not allowed."
        }
    }
}

