import SwiftUI

struct DefaultView: View {
    @State private var searchText = ""
    @EnvironmentObject private var tabManager: TabManager
    

    private func loadURL() {
        var urlString = searchText
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        tabManager.updateURL(at: tabManager.selectedTabIndex, url: url)
    }
    
    var body: some View {
        VStack() {
            Image("showfer-dark")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .padding(100) 
            
            DefaultSearchBar(text: $searchText, onCommit: loadURL)
                .padding(.horizontal, 24)
                .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct DefaultSearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .onSubmit(onCommit)
            
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}