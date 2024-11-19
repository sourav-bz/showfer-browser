import SwiftUI
import Combine

struct StatusBarController: UIViewControllerRepresentable {
    class StatusBarUIViewController: UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            .lightContent  // This will make the status bar white to contrast with gray background
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Create a view for the status bar background
            let statusBarView = UIView(frame: view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBarView.backgroundColor = UIColor.systemGray // Set your desired gray color here
            view.addSubview(statusBarView)
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = StatusBarUIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.setNeedsStatusBarAppearanceUpdate()
    }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView()
                    .overlay(
                        StatusBarController()
                            .frame(width: 0, height: 0)
                    )
            } else {
                LoginView()
                    .overlay(
                        StatusBarController()
                            .frame(width: 0, height: 0)
                    )
            }
        }
        .environmentObject(authViewModel)
        .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
