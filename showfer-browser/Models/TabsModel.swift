import Foundation
import WebKit

class TabsModel: ObservableObject {
    @Published var tabs: [Tab] = [
        Tab(title: "Google", url: URL(string: "https://www.google.com")!),
        Tab(title: "Apple", url: URL(string: "https://www.apple.com")!)
    ]
    @Published var selectedTabIndex: Int = 0
    
    var selectedTab: Tab? {
        tabs[safe: selectedTabIndex]
    }
    
    func addNewTab() {
        let newTab = Tab(title: "New Tab", url: nil)
        tabs.append(newTab)
        selectedTabIndex = tabs.count - 1
    }
    
    func updateTabURL(at index: Int, with url: URL) {
        guard index >= 0 && index < tabs.count else { return }
        tabs[index].url = url
        tabs[index].title = url.host ?? "New Tab"
    }
    
    func removeTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        tabs.remove(at: index)
        if selectedTabIndex >= tabs.count {
            selectedTabIndex = max(tabs.count - 1, 0)
        }
    }
    
    func selectTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        selectedTabIndex = index
    }
    
    func updateTabNavigation(at index: Int, canGoBack: Bool, canGoForward: Bool) {
        guard index >= 0 && index < tabs.count else { return }
        tabs[index].canGoBack = canGoBack
        tabs[index].canGoForward = canGoForward
    }
    
    func setWebView(at index: Int, webView: WKWebView) {
        guard index >= 0 && index < tabs.count else { return }
        tabs[index].webView = webView
    }
}
