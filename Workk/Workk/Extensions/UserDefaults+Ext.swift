//
//  UserDefaults+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/11/2024.
//

import Foundation

extension UserDefaults {
    private static let lastSubscriptionShownKey = "lastSubscriptionShown"
    private static let lastFullScreenAdShownKey = "lastFullScreenAdShown"
    private static let lastRequestReviewShown = "lastRequestReviewShown"

    /// Checks if the subscription plan can be shown based on the given interval (e.g., 3 days).
    static func canShowSubscriptionPlan(interval: TimeInterval = 3 * 24 * 60 * 60) -> Bool {
        guard let lastShowSubscriptionDate = UserDefaults.standard.object(forKey: lastSubscriptionShownKey) as? Date else {
            return true
        }
        
        return Date().timeIntervalSince(lastShowSubscriptionDate) > interval
    }
    
    static func canShowFullScreenAd(interval: TimeInterval = 4 * 60 * 60) -> Bool {
        guard let lastShowFullScreenAdDate = UserDefaults.standard.object(forKey: lastFullScreenAdShownKey) as? Date else {
            return true
        }
        
        return Date().timeIntervalSince(lastShowFullScreenAdDate) > interval
    }
    
    static func canShowRequestReview(interval: TimeInterval = 10 * 60 * 60) -> Bool {
        guard let lastRequestReviewDate = UserDefaults.standard.object(forKey: lastRequestReviewShown) as? Date else {
            return true
        }
        
        return Date().timeIntervalSince(lastRequestReviewDate) > interval
    }

    /// Updates the last subscription shown date to the current date.
    static func updateSubscriptionShownDate() {
        UserDefaults.standard.set(Date(), forKey: lastSubscriptionShownKey)
    }
    
    static func updateFullScreenAdShownDate() {
        UserDefaults.standard.set(Date(), forKey: lastFullScreenAdShownKey)
    }
    
    static func updateRequestReviewDate() {
        UserDefaults.standard.set(Date(), forKey: lastRequestReviewShown)
    }
}
