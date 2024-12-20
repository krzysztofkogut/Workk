//
//  ProfileViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 11/11/2024.
//

import Combine
import SwiftUI
import Resolver

protocol ProfileViewModelProtocol where Self: ObservableObject {
    var workkPremiumTitle: AttributedString { get }
    var goalsTitle: AttributedString { get }
    var moneyGoalTitle: AttributedString { get }
    var hoursGoalTitle: AttributedString { get }
    var dailyGoalTitle: AttributedString { get }
    var weeklyGoalTitle: AttributedString { get }
    var monthlyGoalTitle: AttributedString { get }
    var yearlyGoalTitle: AttributedString { get }
    var jobsTitle: AttributedString { get }
    var currencyTitle: AttributedString { get }
    var dailyNotificationTitle: AttributedString { get }
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    @Published var iCloudSettings: iCloudSettings = Resolver.resolve()
    let notificationManager: NotificationManager = Resolver.resolve()
    
    private let router: ProfileRouter
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("Wypróbuj Workk premium")
        string.font = .latoRegular(size: 14)
        
        if let range = string.range(of: "Workk") {
            string[range].font = .nunitoBlack(size: 14)
        }
        
        return string
    }
    
    var goalsTitle: AttributedString {
        var string = AttributedString("GOALS")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var moneyGoalTitle: AttributedString {
        var string = AttributedString("HOURS GOAL")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var hoursGoalTitle: AttributedString {
        var string = AttributedString("MONEY GOAL")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var dailyGoalTitle: AttributedString {
        var string = AttributedString("DAYILY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var weeklyGoalTitle: AttributedString {
        var string = AttributedString("WEEKLY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthlyGoalTitle: AttributedString {
        var string = AttributedString("MONTHLY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearlyGoalTitle: AttributedString {
        var string = AttributedString("YEARLY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var jobsTitle: AttributedString {
        var string = AttributedString("JOBS")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var currencyTitle: AttributedString {
        var string = AttributedString("CURRENCY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var dailyNotificationTitle: AttributedString {
        var string = AttributedString("DAILY NOTIFICATION")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    init(router: ProfileRouter) {
        self.router = router
    }
    
    func scheduleDailyNotification(at time: Date) {
        notificationManager.scheduleDailyNotification(at: time)
        notificationManager.scheduleWeeklyNotification(on: 1, at: 18, minute: 0)
    }
    
    func cancelDailyNotification() {
        notificationManager.cancelDailyNotification()
    }
    
    func showJobListView() {
        router.showJobListView()
    }
}
