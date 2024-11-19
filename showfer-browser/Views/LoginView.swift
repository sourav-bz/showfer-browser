import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // Changed to @EnvironmentObject
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Showfer Browser")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .foregroundColor(.red)
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .cornerRadius(10)
            }
            
            // Wrapped in a fixed-width container
            HStack {
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                authViewModel.handleAppleSignIn(credential: appleIDCredential)
                            }
                        case .failure(let error):
                            authViewModel.error = error
                        }
                    }
                )
                .frame(height: 50)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
        }
        .padding()
        .alert("Error", isPresented: Binding(
            get: { authViewModel.error != nil },
            set: { if !$0 { authViewModel.error = nil } }
        )) {
            Button("OK") { authViewModel.error = nil }
        } message: {
            Text(authViewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
}