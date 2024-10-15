import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Showfer Browser")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                Text("Sign in with Google")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                authViewModel.signInWithApple()
            }) {
                Text("Sign in with Apple")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
