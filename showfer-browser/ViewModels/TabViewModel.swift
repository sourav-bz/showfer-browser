import SwiftUI

class TabViewModel: ObservableObject {
    @Published var tabs: [Tab] = [Tab(url: "https://www.google.com", searchText: "")]
    @Published var selectedTabIndex: Int = 0
    
    func addTab(url: String = "https://www.google.com") {
        tabs.append(Tab(url: url, searchText: ""))
        selectedTabIndex = tabs.count - 1
    }
    
    func removeTab(at index: Int) {
        guard index < tabs.count else { return }
        tabs.remove(at: index)
        if selectedTabIndex >= tabs.count {
            selectedTabIndex = max(tabs.count - 1, 0)
        }
    }
    
    func updateTab(at index: Int, with url: String) {
        guard index < tabs.count else { return }
        tabs[index].url = url
        tabs[index].searchText = url
    }
    
    func selectTab(at index: Int) {
        guard index < tabs.count else { return }
        selectedTabIndex = index
    }
    
    var currentTab: Tab? {
        guard !tabs.isEmpty, selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex]
    }
}

struct Tab: Identifiable {
    let id = UUID()
    var url: String
    var searchText: String
    var title: String {
        URL(string: url)?.host ?? "New Tab"
    }
}
