import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tabsModel: TabsModel
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if let selectedTab = tabsModel.tabs[safe: tabsModel.selectedTabIndex] {
                Text(selectedTab.title)
                    .font(.largeTitle)
                
                SearchBar(text: Binding(
                    get: { selectedTab.url?.absoluteString ?? "" },
                    set: { self.searchText = $0 }
                ), onCommit: loadURL)
                .padding()
                
                if let url = selectedTab.url {
                    Text("URL: \(url.absoluteString)")
                        .font(.subheadline)
                }
            } else {
                Text("No tab selected")
                    .font(.largeTitle)
            }
        }
    }
    
    private func loadURL() {
        var urlString = searchText
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        tabsModel.updateTabURL(at: tabsModel.selectedTabIndex, with: url)
        
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Enter URL", text: $text, onCommit: onCommit)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabsModel())
    }
}
