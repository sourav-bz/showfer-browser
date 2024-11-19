// AuthViewModel.swift
import SwiftUI
import AuthenticationServices
import Supabase

class AuthViewModel: NSObject, ObservableObject {
    private let client: SupabaseClient
    @Published var isAuthenticated = false
    @Published var error: Error?
    
    override init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://ikevgyqsjnhlvgxyvyxq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlrZXZneXFzam5obHZneHl2eXhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg5MjAwMDksImV4cCI6MjA0NDQ5NjAwOX0.c281elzZZCvJfI9AgUTPppdf2nej18dMiVVhDJkAPDg"
        )
        super.init()

        // Check for existing session
        Task {
            do {
                if try await client.auth.session != nil {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                }
            } catch {
                print("No existing session")
            }
        }
    }
    
    func signInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    func signInWithGoogle() {
        // Implement Google Sign In
    }
    
    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) {
        guard let idToken = credential.identityToken,
              let tokenString = String(data: idToken, encoding: .utf8) else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
            return
        }
        
        Task {
            do {
                let response = try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: tokenString
                    )
                )
                
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }

    func signOut() {
        Task {
            try await client.auth.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
    }
}

// Extension for ASAuthorizationController delegate
extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleAppleSignIn(credential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

// Extension for presentation context
extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            // This should never happen in practice
            fatalError("No window available")
        }
        return window
    }
}