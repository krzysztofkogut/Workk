//
//  WorkkApp.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import GoogleMobileAds
import Resolver
import StoreKit
import SwiftUI

@main
struct WorkkApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    @State private var inAppNotificationWindow: PassThroughWindow?
    @State private var darkModeAnimationWindow: PassThroughWindow?
    
    let notificationManager: NotificationManager = Resolver.resolve()
    let persistenceManager: PersistanceManager = Resolver.resolve()

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        notificationManager.requestAuthorization()
        notificationManager.scheduleDailyNotification(at: 8, minute: 0)
        notificationManager.scheduleWeeklyNotification(on: 1, at: 18, minute: 0)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainTabView()
                        .preferredColorScheme(userTheme.colorScheme)
                        .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                        .transition(.move(edge: .trailing))
                        .onAppear(perform: {
                            if inAppNotificationWindow == nil {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    let overlayWindow = PassThroughWindow(windowScene: windowScene)
                                    overlayWindow.backgroundColor = .clear
                                    overlayWindow.tag = 0320
                                    let controller = StatusBarBasedController()
                                    controller.view.backgroundColor = .clear
                                    overlayWindow.rootViewController = controller
                                    overlayWindow.isHidden = false
                                    overlayWindow.isUserInteractionEnabled = true
                                    self.inAppNotificationWindow = overlayWindow
                                }
                            }
                            
                            if darkModeAnimationWindow == nil {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    let overlayWindow = PassThroughWindow(windowScene: windowScene)
                                    overlayWindow.backgroundColor = .clear
                                    overlayWindow.tag = 0322
                                    let controller = StatusBarBasedController()
                                    controller.view.backgroundColor = .clear
                                    overlayWindow.rootViewController = controller
                                    overlayWindow.isHidden = false
                                    overlayWindow.isUserInteractionEnabled = true
                                    self.darkModeAnimationWindow = overlayWindow
                                }
                            }
                        })
                } else {
                    OnboardingView()
                        .preferredColorScheme(userTheme.colorScheme)
                }
            }
            .animation(.easeInOut, value: hasSeenOnboarding)
        }
    }
}
