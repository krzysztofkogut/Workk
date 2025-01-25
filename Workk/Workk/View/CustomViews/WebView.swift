//
//  WebView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/01/2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Create a default WKWebpagePreferences object
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true // Enable JavaScript for the web page

        // Assign the preferences to the configuration
        configuration.defaultWebpagePreferences = preferences

        return WKWebView(frame: .zero, configuration: configuration)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct WebViewWithCloseButton: View {
    let url: URL
    let navigationTitle: String
//    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.primary)
                })
        }
    }
}
