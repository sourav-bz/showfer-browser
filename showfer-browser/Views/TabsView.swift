import SwiftUI

struct TabsView: View {
    @ObservedObject var tabManager: TabManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(tabManager.tabs.indices, id: \.self) { index in
                    TabListItem(
                        tab: Binding(
                            get: { tabManager.tabs[index] },
                            set: { tabManager.tabs[index] = $0 }
                        ),
                        isSelected: index == tabManager.selectedTabIndex,
                        onDelete: { deleteTab(at: index) }
                    )
                    .onTapGesture {
                        tabManager.selectedTabIndex = index
                        dismiss()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Tabs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addNewTab) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(hex: "#6D67E4"))
                }
            }
        }
    }

    private func deleteTab(at index: Int) {
        tabManager.removeTab(at: index)
    }

    private func addNewTab() {
        tabManager.addTab(url: URL(string: "about:blank")!)
        dismiss()
    }
}

struct TabListItem: View {
    @Binding var tab: Tab
    let isSelected: Bool
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                if let url = tab.url, let host = url.host {
                    AsyncImage(url: URL(string: "https://\(host)/favicon.ico")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "globe")
                    }
                    .font(.title2)
                    .foregroundColor(Color(hex: "#6D67E4"))
                    .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#6D67E4"))
                        .frame(width: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tab.title.isEmpty ? (tab.url?.host ?? "New Tab") : tab.title)
                        .font(.headline)
                        .lineLimit(1)
                    if let url = tab.url {
                        Text(url.host ?? tab.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Color(isSelected ? .secondarySystemBackground : .systemBackground)
                    .opacity(isSelected ? 1 : 0.1)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(isSelected ? 0.1 : 0),
                radius: isSelected ? 3 : 0,
                x: 0,
                y: 1
            )
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
    }
}