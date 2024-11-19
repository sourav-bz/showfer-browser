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
                // Handle Google Sign In URL
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
