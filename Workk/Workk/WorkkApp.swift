//
//  WorkkApp.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import ActivityKit
import GoogleMobileAds
import Resolver
import RevenueCat
import StoreKit
import SwiftUI
import TipKit

@main
struct WorkkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @AppStorage("iCloudSyncEnabled") private var isICloudSyncEnabled: Bool = false
    @AppStorage("dailyNotificationEnabled") private var isDailyNotificationEnabled: Bool = true
    @AppStorage("dailyNotificationTimeInterval") private var dailyNotificationTimeInterval: Double = Date.now.setDateAtSpecificHourAndMinute(hour: 8, minute: 0)?.timeIntervalSince1970 ?? Date.now.timeIntervalSince1970
    
    private let notificationManager: NotificationManager = Resolver.resolve()
    private let userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    private let purchasesDelegateHandler: PurchasesDelegateHandler = Resolver.resolve()
    
    @StateObject private var persistenceManager: PersistenceManager = PersistenceManager.shared

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["REDACTED_TEST_DEVICE"]

        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault),
        ])
        
        notificationManager.requestAuthorization()
        notificationManager.scheduleWeeklyNotification(on: 1, at: 18, minute: 0)
        
        if isDailyNotificationEnabled {
            notificationManager.cancelDailyNotification()
            notificationManager.scheduleDailyNotification(at: Date(timeIntervalSince1970: dailyNotificationTimeInterval))
        } else {
            notificationManager.cancelDailyNotification()
        }
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.revenueCatApiKey)
        Purchases.shared.delegate = purchasesDelegateHandler
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainTabView()
                        .preferredColorScheme(userTheme.colorScheme)
                        .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                        .transition(.move(edge: .trailing))
                } else {
                    OnboardingView()
                        .preferredColorScheme(userTheme.colorScheme)
                }
            }
            .animation(.easeInOut, value: hasSeenOnboarding)
            .task {
                do {
                    // Fetch the available offerings
                    userSubscriptionViewModel.offerings = try await Purchases.shared.offerings()
                } catch {
                    print("Error fetching offerings: \(error)")
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        stopLiveActivity()
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        stopLiveActivity()
    }
    
    private func stopLiveActivity() {
        for activity in Activity<WorkTimeStatusAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
