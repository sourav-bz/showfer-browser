import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let tabIndex: Int
    let tabManager: TabManager
    
    func makeUIView(context: Context) -> WKWebView {
        print("makeUIView called for tab: \(url.absoluteString)")
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("updateUIView called for tab: \(url.absoluteString)")
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastLoadedURL: URL?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                print("Navigating to: \(url.absoluteString)")
                parent.tabManager.updateTab(at: parent.tabIndex, url: url)
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let currentURL = webView.url else { return }
            
            if currentURL != lastLoadedURL {
                print("WebView did finish navigation for tab: \(currentURL.absoluteString)")
                parent.tabManager.updateTab(at: parent.tabIndex, 
                                            title: webView.title ?? "Untitled", 
                                            url: currentURL, 
                                            canGoBack: webView.canGoBack, 
                                            canGoForward: webView.canGoForward)
                lastLoadedURL = currentURL
            }
        }
    }
}