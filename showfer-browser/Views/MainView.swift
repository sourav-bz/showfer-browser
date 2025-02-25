import SwiftUI
import Combine
import AVFoundation
import Starscream
import WebKit

struct MainView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var tabManager: TabManager
    @StateObject private var transcriptionManager = TranscriptionManager()
    @State private var showCommandSheet = false
    @State private var showSettingsSheet = false
    @State private var selectedBottomTab = 0
    @State private var isOrbExpanded = false
    private let openAIService = OpenAIService()
    @State private var aiResponse = ""
    
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
                        showCommandSheet: $showCommandSheet,
                        aiResponse: $aiResponse,
                        tabManager: tabManager,
                        transcriptionManager: transcriptionManager,
                        openAIService: openAIService
                    )
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                }
                .edgesIgnoringSafeArea(.bottom)
                .sheet(isPresented: $showCommandSheet) {
                    OrbSheet(aiResponse: aiResponse)
                        .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showSettingsSheet) {
                    if authViewModel.isAuthenticated {
                        SettingsSheet()
                            .presentationDetents([.medium])
                    } else {
                        LoginView()
                            .presentationDetents([.large])
                            .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
                                if isAuthenticated {
                                    showSettingsSheet = false
                                }
                            }
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            if tabManager.tabs.isEmpty {
                let blankURL = URL(string: "about:blank")!
                tabManager.addTab(url: blankURL)
            }
        }
    }
}

struct TabBarView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var isOrbExpanded: Bool
    @Binding var showSettingsSheet: Bool
    @Binding var showCommandSheet: Bool
    @Binding var aiResponse: String
    @ObservedObject var tabManager: TabManager
    @ObservedObject var transcriptionManager: TranscriptionManager
    private let openAIService: OpenAIService
    @State private var currentScreenshot: UIImage?
    @State private var keyboardHeight: CGFloat = 0
    
    init(
        isOrbExpanded: Binding<Bool>,
        showSettingsSheet: Binding<Bool>,
        showCommandSheet: Binding<Bool>,
        aiResponse: Binding<String>,
        tabManager: TabManager,
        transcriptionManager: TranscriptionManager,
        openAIService: OpenAIService
    ) {
        self._isOrbExpanded = isOrbExpanded
        self._showSettingsSheet = showSettingsSheet
        self._showCommandSheet = showCommandSheet
        self._aiResponse = aiResponse
        self.tabManager = tabManager
        self.transcriptionManager = transcriptionManager
        self.openAIService = openAIService
    }
    
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
                        let parentWidth = geometry.size.width + 140
                        let expandedWidth = parentWidth - 32
                        
                        // Dynamic height container
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(
                                width: isOrbExpanded ? expandedWidth : 60,
                                height: isOrbExpanded ? nil : 60 // Remove fixed height when expanded
                            )
                            .position(x: geometry.size.width / 2, y: 30)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOrbExpanded)
                        
                        HStack(spacing: 0) {
                            // Modified Orb button with authentication check
                            Button(action: {
                                if authViewModel.isAuthenticated {
                                    withAnimation {
                                        isOrbExpanded.toggle()
                                        if isOrbExpanded {
                                            transcriptionManager.startTranscription()
                                        } else {
                                            transcriptionManager.stopTranscription()
                                        }
                                    }
                                } else {
                                    showSettingsSheet = true  // We'll use this to show login
                                }
                            }) {
                                AnimatedOrb(
                                    width: 50, 
                                    height: 50, 
                                    primaryColor: (authViewModel.isAuthenticated) ? Color(hex: "#6D67E4") : Color.gray,
                                    animate: authViewModel.isAuthenticated ? true : false
                                )
                                .frame(maxWidth: 50, maxHeight: 50)
                            }
                            .padding(.leading, isOrbExpanded ? 8 : 0)
                            
                            // Text that appears when expanded
                            if isOrbExpanded {
                                if transcriptionManager.transcriptText.isEmpty {
                                    Text("Just say what you need")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .id("transcriptText")
                                        .transition(.opacity)
                                        .font(.system(size: 16, weight: .medium))
                                } else {
                                    ScrollViewReader { scrollProxy in
                                        ScrollView {
                                            // Transcript Text
                                            Text(transcriptionManager.transcriptText)
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 16)
                                                .padding(.vertical, 8)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .id("transcriptText")
                                                .transition(.opacity)
                                        }
                                        .frame(maxHeight: 200)
                                        .onChange(of: transcriptionManager.transcriptText) { _ in
                                                withAnimation {
                                                    scrollProxy.scrollTo("transcriptText", anchor: .bottom)
                                                }
                                        }
                                    }
                                }

                                // Action button (close or go)
                                Button(action: {
                                    withAnimation {
                                        if transcriptionManager.transcriptText.isEmpty {
                                            isOrbExpanded = false
                                            transcriptionManager.stopTranscription()
                                        } else {
                                            Task {
                                                do {
                                                    // Get WebView from TabManager's current tab
                                                    let base64Image: String
                                                    
                                                    print("Debug: Starting screenshot capture")
                                                    if let webView = tabManager.getCurrentWebView() {
                                                        print("Debug: WebView obtained:", webView)
                                                        do {
                                                            print("Debug: Attempting to take snapshot...")
                                                            let config = WKSnapshotConfiguration()
                                                            let screenshot = try await webView.takeSnapshot(configuration: config)
                                                            print("Debug: Screenshot captured successfully")
                                                            
                                                            if let imageData = screenshot.jpegData(compressionQuality: 0.6) {
                                                                print("Debug: Image data converted successfully, size: \(imageData.count) bytes")
                                                                base64Image = imageData.base64EncodedString()
                                                                print("Debug: Base64 conversion successful, length: \(base64Image.count)")
                                                            } else {
                                                                print("Debug: Failed to convert screenshot to JPEG data")
                                                                base64Image = ""
                                                            }
                                                        } catch {
                                                            print("Debug: Screenshot capture failed with error:", error)
                                                            base64Image = ""
                                                        }
                                                    } else {
                                                        print("Debug: getCurrentWebView() returned nil")
                                                        base64Image = ""
                                                    }
                                                    
                                                    let response = try await openAIService.generateResponse(
                                                        for: transcriptionManager.transcriptText,
                                                        screenshotBase64: base64Image
                                                    )
                                                        
                                                    await MainActor.run {
                                                        switch response {
                                                        case .text(let content):
                                                                print("Showing text response:", content) // Debug print
                                                                aiResponse = content
                                                                showCommandSheet = true
                                                            case .search(let query):
                                                                print("Performing search for:", query) // Debug print
                                                                if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                                                   let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                                                                    print("Opening URL:", url) // Debug print
                                                                    tabManager.addTab(url: url)
                                                                }
                                                            case .input(let text):
                                                                print("Input text:", text) // Debug print
                                                                tabManager.performTextInput(at: tabManager.selectedTabIndex, text: text)
                                                            }

                                                            transcriptionManager.transcriptText = ""
                                                            isOrbExpanded = false
                                                            transcriptionManager.stopTranscription()
                                                        }
                                                    
                                                } catch {
                                                    print("Error getting AI response:", error)
                                                    // Handle error appropriately
                                                }
                                            }
                                        }
                                    }
                                }) {
                                    Image(systemName: transcriptionManager.transcriptText.isEmpty ? "xmark" : "arrow.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(transcriptionManager.transcriptText.isEmpty ? 
                                                    Color.gray.opacity(0.3) : 
                                                    Color(hex: "#6D67E4"))
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
        .offset(y: -keyboardHeight)
        .onAppear {
            setupKeyboardNotifications()
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
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