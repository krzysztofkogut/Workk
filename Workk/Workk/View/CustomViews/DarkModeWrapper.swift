//
//  DarkModeWrapper.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/12/2023.
//

import SwiftUI

struct DarkModeWrapper<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var overlayWindow: UIWindow?
    @AppStorage("activateDarkMode") private var activateDarkMode: Bool = false
    var body: some View {
        content
            .onAppear(perform: {
                if overlayWindow == nil {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        let overlayWindow = UIWindow(windowScene: windowScene)
                        overlayWindow.tag = 0322
                        overlayWindow.isHidden = false
                        overlayWindow.isUserInteractionEnabled = false
                        self.overlayWindow = overlayWindow
                    }
                }
            })
            .onChange(of: activateDarkMode) { newValue in
                if let keyWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) {
                    keyWindow.overrideUserInterfaceStyle = newValue ? .dark : .light
                }
            }
    }
}
