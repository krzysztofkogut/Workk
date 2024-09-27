//
//  ViewSizeReader.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//

import SwiftUI

struct ViewSizeReader: UIViewControllerRepresentable {
    @Binding var size: CGSize
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let window = uiViewController.view.window, let screen = window.windowScene?.screen {
                self.size = screen.bounds.size
            }
        }
    }
}
