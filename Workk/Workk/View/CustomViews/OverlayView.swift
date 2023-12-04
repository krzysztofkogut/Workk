//
//  OverlayView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/12/2023.
//

import SwiftUI

struct OverlayView: View {
    var buttonRect: CGRect
    @State var previousImage: UIImage?
    @State var currentImage: UIImage?
    /// View Properties
    @State private var maskAnimation: Bool = false
    var body: some View {
        GeometryReader(content: { geometry in
            let size = geometry.size
            let maskRadius = size.height / 10
            
            if let previousImage, let currentImage {
                ZStack {
                    Image(uiImage: previousImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                    
                    Image(uiImage: currentImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                        .mask(alignment: .topLeading) {
                            Circle()
                                .frame(width: buttonRect.width * (maskAnimation ? maskRadius : 1), height: buttonRect.height * (maskAnimation ? maskRadius : 1), alignment: .bottomLeading)
                                .frame(width: buttonRect.width, height: buttonRect.height)
                                .offset(x: buttonRect.minX, y: buttonRect.minY)
                                .ignoresSafeArea()
                        }
                }
                .task {
                    guard !maskAnimation else { return }
                    
                    withAnimation(.easeInOut(duration: 0.9), completionCriteria: .logicallyComplete) {
                        maskAnimation = true
                    } completion: {
                        self.previousImage = nil
                        self.currentImage = nil
                        maskAnimation = false
                        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
                            /// Removing all views from the Overlay Window
                            for view in window.subviews {
                                view.removeFromSuperview()
                            }
                            window.isUserInteractionEnabled = false
                        }
                    }
                }
            }
        })
        /// Reverse Masking
        .mask({
            Rectangle()
                .overlay(alignment: .topLeading) {
                    Circle()
                        .frame(width: buttonRect.width, height: buttonRect.height)
                        .offset(x: buttonRect.minX, y: buttonRect.minY)
                        .blendMode(.destinationOut)
                }
        })
        .ignoresSafeArea()
    }
}
