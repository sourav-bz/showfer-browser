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
        let newTab = Tab(title: "New Tab", url: url, history: [url], currentHistoryIndex: 0)
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
 
    func updateURL(at index: Int, url: URL) {
        guard index < tabs.count else { return }
        tabs[index].url = url
        objectWillChange.send()
    }
    
    func updateTab(at index: Int, title: String? = nil, url: URL? = nil) {
        guard index < tabs.count else { return }
        if let title = title {
            tabs[index].title = title
        }
        if let url = url {
            if tabs[index].url != url {
                tabs[index].history.append(url)
                tabs[index].currentHistoryIndex = tabs[index].history.count - 1
            }
            tabs[index].url = url
        }
        
        // Update canGoBack and canGoForward based on history
        tabs[index].canGoBack = tabs[index].currentHistoryIndex > 0
        tabs[index].canGoForward = tabs[index].currentHistoryIndex < tabs[index].history.count - 1
    }
    
    func setWebView(at index: Int, webView: WKWebView) {
        guard index < tabs.count else { return }
        tabs[index].webView = webView
    }
    
    func goBack(at index: Int) {
        print("History: \(tabs[index].history)")
        print("Current History Index: \(tabs[index].currentHistoryIndex)")
        guard index < tabs.count, 
              tabs[index].currentHistoryIndex > 0 else { return }
        
        tabs[index].currentHistoryIndex -= 1
        tabs[index].url = tabs[index].history[tabs[index].currentHistoryIndex]
        tabs[index].canGoForward = true
        tabs[index].canGoBack = tabs[index].currentHistoryIndex > 0
        objectWillChange.send()
    }
    
    func goForward(at index: Int) {
        guard index < tabs.count, 
              tabs[index].currentHistoryIndex < tabs[index].history.count - 1 else { return }
        
        tabs[index].currentHistoryIndex += 1
        tabs[index].url = tabs[index].history[tabs[index].currentHistoryIndex]
        tabs[index].canGoBack = true
        tabs[index].canGoForward = tabs[index].currentHistoryIndex < tabs[index].history.count - 1
        objectWillChange.send()
    }
}
