import Foundation
import WebKit
import UIKit

class TabManager: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var selectedTabIndex: Int = 0
    
    var selectedTab: Tab? {
        guard selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex]
    }
    
    func addTab(url: URL) {
        let newTab = Tab(title: "New Tab", url: url, currentHistoryIndex: 0)
        tabs.append(newTab)
        selectedTabIndex = tabs.count - 1
    }
    
    func removeTab(at index: Int) {
        guard index < tabs.count else { return }
        tabs.remove(at: index)
        if selectedTabIndex >= tabs.count {
            selectedTabIndex = max(tabs.count - 1, 0)
        }
    }
 
    func updateURL(at index: Int, url: URL) {
        guard index < tabs.count else { return }
        tabs[index].url = url
        objectWillChange.send()
    }
    
    func updateTab(at index: Int, title: String? = nil, url: URL? = nil, webView: WKWebView? = nil) {
        guard index < tabs.count else { return }
        if let title = title {
            tabs[index].title = title
        }
        if let url = url {
            if tabs[index].url != url {
                tabs[index].history.append(url)
                tabs[index].currentHistoryIndex = tabs[index].history.count - 1
            }
            tabs[index].url = url
        }
        if let webView = webView {
            tabs[index].webView = webView
        }
        
        // Update canGoBack and canGoForward based on history
        tabs[index].canGoBack = tabs[index].currentHistoryIndex > 0
        tabs[index].canGoForward = tabs[index].currentHistoryIndex < tabs[index].history.count - 1
    }
    
    func setWebView(at index: Int, webView: WKWebView) {
        guard index < tabs.count else { return }
        tabs[index].webView = webView
    }
    
    func goBack(at index: Int) {
        print("History: \(tabs[index].history)")
        print("Current History Index: \(tabs[index].currentHistoryIndex)")
        guard index < tabs.count, 
              tabs[index].currentHistoryIndex > 0 else { return }
        
        tabs[index].currentHistoryIndex -= 1
        tabs[index].url = tabs[index].history[tabs[index].currentHistoryIndex]
        tabs[index].canGoForward = true
        tabs[index].canGoBack = tabs[index].currentHistoryIndex > 0
        objectWillChange.send()
    }
    
    func goForward(at index: Int) {
        guard index < tabs.count, 
              tabs[index].currentHistoryIndex < tabs[index].history.count - 1 else { return }
        
        tabs[index].currentHistoryIndex += 1
        tabs[index].url = tabs[index].history[tabs[index].currentHistoryIndex]
        tabs[index].canGoBack = true
        tabs[index].canGoForward = tabs[index].currentHistoryIndex < tabs[index].history.count - 1
        objectWillChange.send()
    }

    func getCurrentWebView() -> WKWebView? {
        guard !tabs.isEmpty, 
              selectedTabIndex < tabs.count,
              let webView = tabs[selectedTabIndex].webView else {
            print("Debug: getCurrentWebView failed - tabs.count: \(tabs.count), selectedTabIndex: \(selectedTabIndex)")
            return nil
        }
        return webView
    }
    
    func performTextInput(at index: Int, text: String) {
        guard index < tabs.count, let webView = tabs[index].webView else { return }
        
        let simulationFunction = """
        window.simulateInputEvents = function(element, value) {
            element.focus();
            element.dispatchEvent(new Event('focus', { bubbles: true }));
            
            element.value = '';
            element.value = value;
            
            for (let i = 0; i < value.length; i++) {
                const char = value[i];
                
                element.dispatchEvent(new KeyboardEvent('keydown', {
                    key: char,
                    code: 'Key' + char.toUpperCase(),
                    bubbles: true,
                    cancelable: true,
                    keyCode: char.charCodeAt(0),
                    which: char.charCodeAt(0)
                }));
                
                element.dispatchEvent(new InputEvent('input', {
                    bubbles: true,
                    cancelable: true,
                    data: char,
                    inputType: 'insertText'
                }));
                
                element.dispatchEvent(new KeyboardEvent('keyup', {
                    key: char,
                    code: 'Key' + char.toUpperCase(),
                    bubbles: true,
                    cancelable: true,
                    keyCode: char.charCodeAt(0),
                    which: char.charCodeAt(0)
                }));
            }
            
            element.dispatchEvent(new Event('change', { bubbles: true }));
            
            if (element.form) {
                element.form.dispatchEvent(new Event('input', { bubbles: true }));
                element.form.dispatchEvent(new Event('change', { bubbles: true }));
                
                if (element.checkValidity()) {
                    element.dispatchEvent(new Event('valid', { bubbles: true }));
                    const submitBtn = element.form.querySelector('button[type="submit"]');
                    if (submitBtn && element.form.checkValidity()) {
                        submitBtn.disabled = false;
                        submitBtn.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                }
            }
        }
        """
        
        webView.evaluateJavaScript(simulationFunction) { _, _ in
            let escapedText = text.replacingOccurrences(of: "'", with: "\\'")
                                .replacingOccurrences(of: "\"", with: "\\\"")
            
            let inputScript = """
            (function() {
                const element = document.activeElement;
                if (element && ['INPUT', 'TEXTAREA'].includes(element.tagName)) {
                    window.simulateInputEvents(element, "\(escapedText)");
                    return true;
                }
                return false;
            })();
            """
            
            webView.evaluateJavaScript(inputScript) { result, error in
                if let error = error {
                    print("Error executing text input JavaScript: \(error)")
                } else if let success = result as? Bool {
                    print("Text input applied: \(success)")
                }
            }
        }
    }
}
