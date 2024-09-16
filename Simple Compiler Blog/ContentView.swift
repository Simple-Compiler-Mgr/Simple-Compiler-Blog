//
//  ContentView.swift
//  Simple Compiler Blog
//
//  Created by zuole on 9/16/24.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var webViewStore = WebViewStore()
    
    var body: some View {
        WebView(url: URL(string: "https://blog.sc.000708.xyz")!, webViewStore: webViewStore)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack(spacing: 10) {
                        Button(action: {
                            webViewStore.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!webViewStore.canGoBack)
                        
                        Button(action: {
                            webViewStore.goForward()
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!webViewStore.canGoForward)
                        
                        Button(action: {
                            webViewStore.goHome()
                        }) {
                            Image(systemName: "house")
                        }
                    }
                }
            }
    }
}

class WebViewStore: ObservableObject {
    @Published var webView: WKWebView?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func goHome() {
        if let url = URL(string: "https://blog.sc.000708.xyz") {
            webView?.load(URLRequest(url: url))
        }
    }
}

struct WebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var webViewStore: WebViewStore
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webViewStore.webView = webView
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 不需要在这里重新加载页面
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("网页加载完成")
            DispatchQueue.main.async {
                self.parent.webViewStore.canGoBack = webView.canGoBack
                self.parent.webViewStore.canGoForward = webView.canGoForward
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("网页加载失败: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.webViewStore.canGoBack = webView.canGoBack
                self.parent.webViewStore.canGoForward = webView.canGoForward
            }
        }
    }
}

#Preview {
    ContentView()
}
