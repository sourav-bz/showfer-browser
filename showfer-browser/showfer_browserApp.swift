//
//  showfer_browserApp.swift
//  showfer-browser
//
//  Created by Sourav on 14/10/24.
//

import SwiftUI
import GoogleSignIn

@main
struct showfer_browserApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var tabManager = TabManager()
    
    init() {
        // Configure Google Sign In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "65942031867-33k2fa9vn9iqrjueiuqkughoil7vrr25.apps.googleusercontent.com"
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(tabManager)
                // Handle both Google Sign In and browser URLs
                .onOpenURL { url in
                    if url.scheme == "com.googleusercontent.apps.65942031867-33k2fa9vn9iqrjueiuqkughoil7vrr25" {
                        GIDSignIn.sharedInstance.handle(url)
                    } else {
                        // Handle browser URLs
                        handleIncomingURL(url)
                    }
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Make sure it's a valid http/https URL
        guard url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https" else {
            return
        }
        
        // Add new tab with the URL
        tabManager.addTab(url: url)
    }
}
