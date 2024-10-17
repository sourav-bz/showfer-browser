import Foundation
import WebKit

class TabManager: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var selectedTabIndex: Int = 0
    
    var selectedTab: Tab? {
        guard selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex]
    }
    
    func addTab(url: URL) {
        let newTab = Tab(title: "New Tab", url: url)
        tabs.append(newTab)
        selectedTabIndex = tabs.count - 1
    }
    
    func removeTab(at index: Int) {
        guard index < tabs.count else { return }
        tabs.remove(at: index)
        if selectedTabIndex >= tabs.count {
            selectedTabIndex = max(tabs.count - 1, 0)
        }
    }
    
    func updateTab(at index: Int, title: String? = nil, url: URL? = nil, canGoBack: Bool? = nil, canGoForward: Bool? = nil) {
        guard index < tabs.count else { return }
        if let title = title {
            tabs[index].title = title
        }
        if let url = url {
            tabs[index].url = url
        }
        if let canGoBack = canGoBack {
            tabs[index].canGoBack = canGoBack
        }
        if let canGoForward = canGoForward {
            tabs[index].canGoForward = canGoForward
        }
    }
    
    func setWebView(at index: Int, webView: WKWebView) {
        guard index < tabs.count else { return }
        tabs[index].webView = webView
    }
}