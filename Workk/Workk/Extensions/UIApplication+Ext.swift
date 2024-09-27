//
//  UIApplication+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/12/2023.
//

import SwiftUI

extension UIApplication {
    func getRootViewController() -> UIViewController {
        guard let screen = connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.last?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func inAppNotification<Content: View>(adaptForDynamicIsland: Bool = false, timeout: CGFloat = 5, swipeToClose: Bool = true, @ViewBuilder content: @escaping (Bool) -> Content) {
        /// Fetching Active Window VIA WindowScene
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
            /// Frame and SafeArea Values
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets
            
            var tag = 1009
            let checkForDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
            
            if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
                tag = previousTag + 1
            }
            
            UserDefaults.standard.setValue(tag, forKey: "in_app_notification_tag")
            
            /// Changing Status into Black to blend with Dynamic Island
            if checkForDynamicIsland {
                if let controller = activeWindow.rootViewController as? StatusBarBasedController {
                    controller.statusBarStyle = .darkContent
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
            
            /// Creating UIView from SwiftUIView using UIHosting Configuration
            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(checkForDynamicIsland),
                    safeArea: safeArea,
                    tag: tag,
                    adaptForDynamicIsland: checkForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose
                )
                /// Maximum Notification Height will be 120
                .frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
                .contentShape(.rect)
            }
            
            /// Creating UIView
            let view = config.makeContentView()
            view.tag = tag
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if let rootView = activeWindow.rootViewController?.view {
                /// Adding View to the Window
                rootView.addSubview(view)
                
                /// Layout Constraints
                view.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: (-(frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
            }
        }
    }
}
