import Foundation
import WebKit

struct Tab: Identifiable {
    let id = UUID()
    var title: String
    var url: URL?
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var webView: WKWebView?
    var history: [URL] = []
    var currentHistoryIndex: Int = -1
}
