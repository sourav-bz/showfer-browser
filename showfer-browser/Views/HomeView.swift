import SwiftUI
import WebKit

struct HomeView: View {
    @ObservedObject var tabManager: TabManager
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if let selectedTab = tabManager.selectedTab {
                SearchBar(text: Binding(
                    get: { selectedTab.url?.absoluteString ?? "" },
                    set: { self.searchText = $0 }
                ), onCommit: loadURL,
                   onBack: goBack,
                   onForward: goForward)
                .padding()

                WebView(url: selectedTab.url ?? URL(string: "about:blank")!,
                    tabIndex: tabManager.selectedTabIndex,
                    tabManager: tabManager)
                .edgesIgnoringSafeArea(.bottom)
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
        tabManager.updateTab(at: tabManager.selectedTabIndex, url: url)
    }
    
    private func goBack() {
        tabManager.selectedTab?.webView?.goBack()
    }
    
    private func goForward() {
        tabManager.selectedTab?.webView?.goForward()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void
    var onBack: () -> Void
    var onForward: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
            }
            
            Button(action: onForward) {
                Image(systemName: "chevron.right")
            }
            
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
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}