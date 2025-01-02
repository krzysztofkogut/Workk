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
    let regionCode = Locale.current.region?.identifier
    let currencyCode = Locale.current.currency?.identifier
    
    private let router: ProfileRouter
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("try_workk_premium_title".localized)
        string.font = .latoRegular(size: 14)
        
        if let range = string.range(of: "workk_title".localized) {
            string[range].font = .nunitoBlack(size: 14)
        }
        
        return string
    }
    
    var goalsTitle: AttributedString {
        var string = AttributedString("goals_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var dailyGoalTitle: AttributedString {
        var string = AttributedString("daily_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var weeklyGoalTitle: AttributedString {
        var string = AttributedString("weekly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthlyGoalTitle: AttributedString {
        var string = AttributedString("monthly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearlyGoalTitle: AttributedString {
        var string = AttributedString("yearly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var jobsTitle: AttributedString {
        var string = AttributedString("jobs_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var currencyTitle: AttributedString {
        var string = AttributedString("currency_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var dailyNotificationTitle: AttributedString {
        var string = AttributedString("notification_title".localized.uppercased())
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
