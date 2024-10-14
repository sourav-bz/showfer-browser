//
//  showfer_browserApp.swift
//  showfer-browser
//
//  Created by Sourav on 14/10/24.
//

import SwiftUI

@main
struct showfer_browserApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
