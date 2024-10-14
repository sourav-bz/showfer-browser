import SwiftUI

struct TabsView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    
    let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        NavigationView {
            Group {
                if tabViewModel.tabs.isEmpty {
                    noTabsView
                } else {
                    tabsGridView
                }
            }
            .navigationTitle("Tabs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { tabViewModel.addTab() }) {
                        Image(systemName: "plus")
                    }
                }
            }
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
    
    private var tabsGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(tabViewModel.tabs.indices, id: \.self) { index in
                    TabItemView(tab: tabViewModel.tabs[index], isSelected: index == tabViewModel.selectedTabIndex)
                        .onTapGesture {
                            tabViewModel.selectTab(at: index)
                        }
                        .overlay(
                            Button(action: {
                                tabViewModel.removeTab(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .opacity(0.8)
                            }
                            .padding(5),
                            alignment: .topTrailing
                        )
                }
            }
            .padding()
        }
    }
}

struct TabItemView: View {
    let tab: Tab
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(tab.title)
                .font(.headline)
                .lineLimit(1)
            Text(tab.url)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 150, height: 100)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
            .environmentObject(TabViewModel())
    }
}
