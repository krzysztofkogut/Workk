//
//  WorkkApp.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import Resolver
import SwiftUI

@main
struct WorkkApp: App {
    @State private var overlayWindow: PassThroughWindow?
    
    var body: some Scene {
        WindowGroup {
                MainTabView()
                    .environment(\.locale, .init(identifier: "pl"))
                    .onAppear(perform: {
                        if overlayWindow == nil {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                let overlayWindow = PassThroughWindow(windowScene: windowScene)
                                overlayWindow.backgroundColor = .clear
                                overlayWindow.tag = 0320
                                let controller = StatusBarBasedController()
                                controller.view.backgroundColor = .clear
                                overlayWindow.rootViewController = controller
                                overlayWindow.isHidden = false
                                overlayWindow.isUserInteractionEnabled = true
                                self.overlayWindow = overlayWindow
                                //print("Overlay Window Created")
                            }
                        }
                    })
        }
    }
}
