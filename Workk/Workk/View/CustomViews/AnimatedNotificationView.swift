//
//  AnimatedNotificationView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/12/2023.
//

import SwiftUI

struct AnimatedNotificationView<Content: View>: View {
    var content: Content
    var safeArea: UIEdgeInsets
    var tag: Int
    var adaptForDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    /// View Properties
    @State private var animateNotification: Bool = false
    @State private var viewSize: CGSize = .zero
    var body: some View {
        content
            .zIndex(10000)
            .opacity(adaptForDynamicIsland ? (animateNotification ? 1 : 0) : 1)
            .blur(radius: animateNotification ? 0 : 10)
            .disabled(!animateNotification)
            .size {
                viewSize = $0
            }
            .background(content: {
                if adaptForDynamicIsland {
                    Rectangle()
//                        .fill(.black)
                }
            })
            .mask {
                if adaptForDynamicIsland {
                    /// Size Based Capusule
                    GeometryReader(content: { geometry in
                        let size = geometry.size
                        let radius = size.height / 2
                        
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                    })
                } else {
                    Rectangle()
                }
            }
            /// Scaling Animation only For Dynamic Island Notification
            /// Approx Dynamic Island Size = (126, 37.33)
            .scaleEffect(
                x: adaptForDynamicIsland ? (animateNotification ? 1 : (120 / viewSize.width)) : 1,
                y: adaptForDynamicIsland ? (animateNotification ? 1 : (35 / viewSize.height)) : 1,
                anchor: .top
            )
            /// Offset Animation for Non Dynamic Island Notification
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if -value.translation.height > 50, swipeToClose {
                            withAnimation(.smooth) {
                                animateNotification = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                removeNotificationViewFromWindow()
                            }
                        }
                    }
            )
            .onAppear(perform: {
                Task {
                    guard !animateNotification else { return }
                    withAnimation(.smooth) {
                        animateNotification = true
                    }
                    
                    /// Timeout For Notification
                    try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
                    
                    guard animateNotification else { return }
                    
                    withAnimation(.smooth) {
                        animateNotification = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        removeNotificationViewFromWindow()
                    }
                }
            })
    }
    
    var offsetY: CGFloat {
        if adaptForDynamicIsland {
            return animateNotification ? 0 : 1.33
        }
        
        return animateNotification ? 10 : -(safeArea.top + 130)
    }
    
    func removeNotificationViewFromWindow() {
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
            if let view = activeWindow.viewWithTag(tag) {
                // print("Removed View with \(tag)")
                view.removeFromSuperview()
                
                /// Resetting Once All the notifications was removed
                if let controller = activeWindow.rootViewController as? StatusBarBasedController, controller.view.subviews.isEmpty {
                    controller.statusBarStyle = .default
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
}
