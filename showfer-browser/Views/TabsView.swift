import SwiftUI

struct TabsView: View {
    @EnvironmentObject var tabsModel: TabsModel

    // Define the grid layout
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(tabsModel.tabs.indices, id: \.self) { index in
                    TabGridItem(
                        tab: Binding(
                            get: { tabsModel.tabs[index] },
                            set: { tabsModel.tabs[index] = $0 }
                        ),
                        isSelected: index == tabsModel.selectedTabIndex,
                        onDelete: { deleteTab(at: index) }
                    )
                    .onTapGesture {
                        tabsModel.selectTab(at: index)
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
                }
            }
        }
    }

    private func deleteTab(at index: Int) {
        tabsModel.removeTab(at: index)
    }

    private func addNewTab() {
        tabsModel.addNewTab()
    }
}

struct TabGridItem: View {
    @Binding var tab: Tab
    let isSelected: Bool
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(systemName: "globe")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text(tab.title)
                    .font(.headline)
                    .lineLimit(1)
                if let url = tab.url {
                    Text(url.host ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No URL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .offset(y: 5)
                }
            }
            .frame(height: 120)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
    }
}
