import SwiftUI
import AuthenticationServices

// LoginView.swift
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Showfer Browser")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Google Sign In Button
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                HStack {
                    Image("google_logo") // Make sure to add this to your assets
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Apple Sign In Button
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