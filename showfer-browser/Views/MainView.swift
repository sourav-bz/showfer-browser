import SwiftUI
import Combine

struct MainView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var tabManager = TabManager()
    @State private var showCommandSheet = false
    @State private var showSettingsSheet = false
    @State private var selectedBottomTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content area
                HomeView(tabManager: tabManager)
                    .padding(.bottom, 60) // Add bottom padding to avoid overlap with tab bar
                
                // Custom tab bar at the bottom
                VStack {
                    Spacer()
                    HStack {
                        NavigationLink(destination: TabsView(tabManager: tabManager)) {
                            VStack {
                                Image("tabs")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 34, height: 34) 
                            }
                        }
                        Spacer()
                        AnimatedOrb(width: 45, height: 45, primaryColor: .blue)
                        Spacer()
                        Button(action: { showSettingsSheet = true }) {
                            VStack {
                                Image(systemName: "ellipsis")
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -5)
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
