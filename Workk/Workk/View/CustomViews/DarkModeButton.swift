//
//  DarkModeButton.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/12/2023.
//

import SwiftUI

struct DarkModeButton: View {
    @State private var buttonRect: CGRect = .zero
    @State private var isButtonSelected: Bool = false
    @AppStorage("toggleDarkMode") private var toggleDarkMode: Bool = false
    @AppStorage("activateDarkMode") private var activateDarkMode: Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    var body: some View {
        Button(action: {
            toggleDarkMode.toggle()
            userTheme = toggleDarkMode ? .dark : .light
            animateScheme()
        }, label: {
            Image(systemName: userTheme == .dark ? "sun.max.fill" : "moon.fill")
                .addSymbolEffect(isSelected: isButtonSelected)
                .font(.title2)
                .foregroundStyle(.blackWhite)
                .frame(width: 40, height: 40)
        })
        .buttonStyle(.plain)
        .rect { rect in
            buttonRect = rect
        }
    }
    
    @MainActor
    func animateScheme() {
        Task {
            if let windows = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows, let window = windows.first(where: { $0.isKeyWindow }), let overlayWindow = windows.first(where: { $0.tag == 0322 }) {
                overlayWindow.isUserInteractionEnabled = true
                let imageView = UIImageView()
                imageView.frame = window.frame
                imageView.image = window.image(window.frame.size)
                imageView.contentMode = .scaleAspectFit
                overlayWindow.addSubview(imageView)
                
                let frameSize = window.frame.size
                /// Creating Snapshots
                /// Old One
                activateDarkMode = !toggleDarkMode
                let previousImage = window.image(frameSize)
                /// New One with Updated Trait State
                activateDarkMode = toggleDarkMode
                /// Giving some time to complete the transition
                try await Task.sleep(for: .seconds(0.01))
                let currentImage = window.image(frameSize)
                
                try await Task.sleep(for: .seconds(0.01))
                
                let swiftUIView = OverlayView(buttonRect: buttonRect, previousImage: previousImage, currentImage: currentImage)
                
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.view.backgroundColor = .clear
                hostingController.view.frame = window.frame
                hostingController.view.tag = 1009
                overlayWindow.addSubview(hostingController.view)
                imageView.removeFromSuperview()
            }
        }
    }
}
