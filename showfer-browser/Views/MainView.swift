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
                    .environmentObject(tabManager)
                    .padding(.bottom, 60) // Add bottom padding to avoid overlap with tab bar
                
                // Custom tab bar at the bottom
                VStack {
                    Spacer()
                    HStack {
                        NavigationLink(destination: TabsView(tabManager: tabManager)) {
                            VStack {
                                Image("tab")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 34, height: 34)
                                    .shadow(radius: 0)
                            }
                        }
                        Spacer()
                        AnimatedOrb(width: 60, height: 60, primaryColor: Color(hex: "#6D67E4"))
                        .frame(maxWidth: 60, maxHeight: 60)
                        Spacer()
                        Button(action: { showSettingsSheet = true }) {
                            VStack {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color(hex: "#8F93A5"))
                            }
                        }
                    }
                    .padding()
                    .background(
                        Color.white
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                            )
                    )
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}