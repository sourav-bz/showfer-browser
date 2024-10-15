import SwiftUI
import Combine

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var tabsModel = TabsModel()
    @State private var showCommandSheet = false
    @State private var showSettingsSheet = false
    @State private var selectedBottomTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content area
                HomeView()
                    .environmentObject(tabsModel)
                
                // Custom tab bar at the bottom
                VStack {
                    Spacer()
                    HStack {
                        NavigationLink(destination: TabsView().environmentObject(tabsModel)) {
                            VStack {
                                Image(systemName: "square.on.square")
                                Text("Tabs")
                            }
                        }
                        Spacer()
                        Button(action: { showCommandSheet = true }) {
                            VStack {
                                Image(systemName: "circle.fill")
                                Text("Orb")
                            }
                        }
                        Spacer()
                        Button(action: { showSettingsSheet = true }) {
                            VStack {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
            }
            .sheet(isPresented: $showCommandSheet) {
                OrbSheet()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsSheet()
                    .presentationDetents([.medium])
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
