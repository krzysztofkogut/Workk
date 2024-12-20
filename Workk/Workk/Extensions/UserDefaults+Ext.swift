//
//  UserDefaults+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/11/2024.
//

import Foundation

extension UserDefaults {
    private static let lastSubscriptionShownKey = "lastSubscriptionShown"

    /// Checks if the subscription plan can be shown based on the given interval (e.g., 7 days).
    static func canShowSubscriptionPlan(interval: TimeInterval = 7 * 24 * 60 * 60) -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: lastSubscriptionShownKey) as? Date else {
            return true // No record means we can show it
        }
        return Date().timeIntervalSince(lastDate) > interval
    }

    /// Updates the last subscription shown date to the current date.
    static func updateSubscriptionShownDate() {
        UserDefaults.standard.set(Date(), forKey: lastSubscriptionShownKey)
    }
}
