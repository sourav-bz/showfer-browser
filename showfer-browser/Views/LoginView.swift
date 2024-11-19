import SwiftUI
import AuthenticationServices

// LoginView.swift
struct LoginView: View {
    static let Surface: Color = Color(red: 0.94, green: 0.95, blue: 0.97)
    static let Black: Color = Color(red: 0.07, green: 0.06, blue: 0.06)
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Add full screen background
            LoginView.Surface
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("showfer-dark")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)

                    Text("Sign in or Sign up")
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)

                    Spacer()
                        .frame(height: 20)
                    
                    // Google Sign In Button
                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack(alignment: .center, spacing: 5) { Image("google-icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                            .font(
                                .system(size: 16, weight: .medium)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(LoginView.Black) }
                        .padding(10)
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .center)
                        .background(.white)
                        .cornerRadius(10)
                    }
                    
                    // Apple Sign In Button
                    Button(action: {
                        let appleIDProvider = ASAuthorizationAppleIDProvider()
                        let request = appleIDProvider.createRequest()
                        request.requestedScopes = [.email, .fullName]
                        
                        let authController = ASAuthorizationController(authorizationRequests: [request])
                        authController.delegate = authViewModel
                        authController.performRequests()
                    }) {
                        HStack(alignment: .center, spacing: 5) {
                            Image("apple-icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(LoginView.Black)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .center)
                        .background(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Text("By creating an account, you agree to Shower.ai's [Terms of Service](https://www.showfer.ai/terms-and-conditions) and [Privacy Policy](https://www.showfer.ai/privacy-policy).")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding()
        }
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