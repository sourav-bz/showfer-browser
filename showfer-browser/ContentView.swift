//
//  ContentView.swift
//  showfer-browser
//
//  Created by Sourav on 14/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView()
            } else {
                // LoginView()
                MainView()
            }
        }
        .environmentObject(authViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
