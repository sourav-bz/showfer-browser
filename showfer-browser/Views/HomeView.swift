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
                   onForward: goForward,
                   canGoBack: selectedTab.canGoBack,
                   canGoForward: selectedTab.canGoForward)
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
        tabManager.updateURL(at: tabManager.selectedTabIndex, url: url)
    }
    
    private func goBack() {
        tabManager.goBack(at: tabManager.selectedTabIndex)
    }
    
    private func goForward() {
        tabManager.goForward(at: tabManager.selectedTabIndex)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void
    var onBack: () -> Void
    var onForward: () -> Void
    var canGoBack: Bool
    var canGoForward: Bool
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
            }
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1.0 : 0.5)
            
            Button(action: onForward) {
                Image(systemName: "chevron.right")
            }
            .disabled(!canGoForward)
            .opacity(canGoForward ? 1.0 : 0.5)
            
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
