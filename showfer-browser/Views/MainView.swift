import SwiftUI
import Combine
struct MainView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var tabManager = TabManager()
    @State private var showCommandSheet = false
    @State private var showSettingsSheet = false
    @State private var selectedBottomTab = 0
    @State private var isOrbExpanded = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    // Main content area
                    HomeView(tabManager: tabManager)
                        .environmentObject(tabManager)
                        .padding(.bottom, 80)
                    
                    // Custom tab bar at the bottom
                    TabBarView(
                        isOrbExpanded: $isOrbExpanded,
                        showSettingsSheet: $showSettingsSheet,
                        tabManager: tabManager
                    )
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                }
                .edgesIgnoringSafeArea(.bottom)
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
        .preferredColorScheme(.light)
    }
}

struct TabBarView: View {
    @Binding var isOrbExpanded: Bool
    @Binding var showSettingsSheet: Bool
    @ObservedObject var tabManager: TabManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Left Tab Button with fixed width
                NavigationLink(destination: TabsView(tabManager: tabManager)) {
                    VStack {
                        Image("tab")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34, height: 34)
                            .shadow(radius: 0)
                    }
                }
                .frame(width: 44)
                .opacity(isOrbExpanded ? 0 : 1)
                
                Spacer()
                
                // Center Orb Container
                ZStack {
                    GeometryReader { geometry in
                        let parentWidth = geometry.size.width + 140 // Add back the width of both side buttons
                        let expandedWidth = parentWidth - 32
                        
                        // Animated container
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(
                                width: isOrbExpanded ? expandedWidth : 60,
                                height: 60
                            )
                            .position(x: geometry.size.width / 2, y: 30)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOrbExpanded)
                        
                        HStack(spacing: 0) {
                            // Orb button with animation
                            Button(action: {
                                withAnimation {
                                    isOrbExpanded.toggle()
                                }
                            }) {
                                AnimatedOrb(width: 50, height: 50, primaryColor: Color(hex: "#6D67E4"))
                                    .frame(maxWidth: 50, maxHeight: 50)
                            }
                            .padding(.leading, isOrbExpanded ? 8 : 0)
                            
                            // Text that appears when expanded
                            if isOrbExpanded {
                                Text("Just say what you need")
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16)
                                    .transition(.opacity)
                                
                                // Close button
                                Button(action: {
                                    withAnimation {
                                        isOrbExpanded = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                }
                                .padding(.trailing, 16)
                                .transition(.opacity)
                            }
                        }
                        .frame(width: isOrbExpanded ? expandedWidth : 50)
                        .position(x: geometry.size.width / 2, y: 30)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOrbExpanded)
                    }
                    .frame(height: 60)
                }
                
                Spacer()
                
                // Right Settings Button with fixed width
                Button(action: { showSettingsSheet = true }) {
                    VStack {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(hex: "#8F93A5"))
                    }
                }
                .frame(width: 44)
                .opacity(isOrbExpanded ? 0 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -5)
        }
        .background(Color.clear)
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