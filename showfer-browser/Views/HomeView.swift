import SwiftUI
import WebKit

struct HomeView: View {
    @ObservedObject var tabManager: TabManager
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if let selectedTab = tabManager.selectedTab {
                if selectedTab.url?.absoluteString == "about:blank" {
                    DefaultView()
                } else {
                    SearchBar(text: Binding(
                        get: { selectedTab.url?.absoluteString ?? "" },
                        set: { self.searchText = $0 }
                    ), onCommit: loadURL,
                    onBack: goBack,
                    onForward: goForward,
                    canGoBack: selectedTab.canGoBack,
                    canGoForward: selectedTab.canGoForward)

                    WebView(url: selectedTab.url ?? URL(string: "about:blank")!,
                        tabIndex: tabManager.selectedTabIndex,
                        tabManager: tabManager)
                    .edgesIgnoringSafeArea(.bottom)
                    .id(selectedTab.id)
                }
            } else {
                DefaultView()
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
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Back/Forward Navigation
                HStack(spacing: 4) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 28, height: 28)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                    .disabled(!canGoBack)
                    .opacity(canGoBack ? 1.0 : 0.5)
                    
                    Button(action: onForward) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 28, height: 28)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                    .disabled(!canGoForward)
                    .opacity(canGoForward ? 1.0 : 0.5)
                }
                
                // Search TextField
                HStack {
                    TextField("Search or enter website", text: $text, onCommit: onCommit)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            isEditing = true
                        }
                    
                    Button(action: onCommit) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
}

// Preview provider for SwiftUI Canvas
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(
            text: .constant("twitter.com"),
            onCommit: {},
            onBack: {},
            onForward: {},
            canGoBack: true,
            canGoForward: false
        )
    }
}
