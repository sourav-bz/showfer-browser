import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedTab = 0  // 0 represents the Home tab
    @State private var showCommandSheet = false
    @State private var showSettingsSheet = false
    
    var body: some View {
        ZStack {
            // Main content area
            VStack {
                Spacer()
                Text("Home Screen")
                    .font(.largeTitle)
                Spacer()
            }
            
            // Custom tab bar at the bottom
            VStack {
                Spacer()
                HStack {
                    Button(action: { selectedTab = 1 }) {
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
                .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheet()
                .presentationDetents([.fraction(0.6)])
        }
        .fullScreenCover(isPresented: Binding(
            get: { selectedTab == 1 },
            set: { if !$0 { selectedTab = 0 } }
        )) {
            TabsView()
        }
    }
}
