import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if let currentTab = tabViewModel.currentTab {
                    TabView(tab: binding(for: currentTab))
                } else {
                    noTabsView
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private var noTabsView: some View {
        VStack {
            Text("No tabs to show")
                .font(.headline)
            Button("Open New Tab") {
                tabViewModel.addTab()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func binding(for tab: Tab) -> Binding<Tab> {
        guard let index = tabViewModel.tabs.firstIndex(where: { $0.id == tab.id }) else {
            fatalError("Tab not found")
        }
        return $tabViewModel.tabs[index]
    }
}

struct TabView: View {
    @Binding var tab: Tab
    
    var body: some View {
        VStack {
            SearchBar(text: $tab.searchText, onCommit: loadWebPage)
            WebView(url: tab.url)
        }
    }
    
    private func loadWebPage() {
        guard !tab.searchText.isEmpty else { return }
        let urlString = tab.searchText.hasPrefix("http") ? tab.searchText : "https://\(tab.searchText)"
        tab.url = urlString
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewModel())
    }
}
