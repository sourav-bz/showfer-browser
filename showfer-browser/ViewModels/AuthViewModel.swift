import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    func signInWithGoogle() {
        // Implement Google Sign-In logic here
        // For now, we'll just set isAuthenticated to true
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
    
    func signInWithApple() {
        // Implement Apple Sign-In logic here
        // For now, we'll just set isAuthenticated to true
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
