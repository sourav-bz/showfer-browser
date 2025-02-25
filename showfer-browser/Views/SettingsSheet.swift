import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Button("Sign Out") {
            authViewModel.signOut()
        }
        .foregroundColor(.red)
    }
}
