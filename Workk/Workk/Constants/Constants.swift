//
//  Constants.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/01/2025.
//

import Foundation

struct Constants {
    /// Values are supplied by Configuration/Local.xcconfig via the app Info.plist.
    static func configuration(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty, !value.contains("$("), !value.hasPrefix("REPLACE_") else {
            fatalError("Missing \(key). Configure Workk/Configuration/Local.xcconfig before running.")
        }
        return value
    }

    
    /*
     The API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
     */
    static let revenueCatApiKey = Constants.configuration("REVENUECAT_API_KEY")
    
    /*
     The entitlement ID from the RevenueCat dashboard that is activated upon successful in-app purchase for the duration of the purchase.
     */
    static let monthlyEntitlementID = "Monthly"
    static let annualEntitlementID = "Annual"
    
    static let monthFirstLocales: [String] = ["US", "CA", "PH", "MX"]
    
    static let termsAndConditionsURL = URL(string: "https://www.termsfeed.com/live/261f689d-756c-4e86-b1ef-592380ac6858")!
    static let privacyPolicyURL = URL(string: "https://www.termsfeed.com/live/e3bae724-f2af-4314-8ac6-9e897c78f775")!
    
    static let appURL = URL(string: "https://apps.apple.com/app/id6740149770")!
    static let appStoreReview = URL(string: "https://apps.apple.com/app/id6740149770?action=write-review")!
    
    static let xAppURL = URL(string: "twitter://user?screen_name=workkapp")!
    static let xWebURL = URL(string: "https://x.com/workkapp")!
    
    static let instagramURL = URL(string: "instagram://user?username=workkapp")!
    static let instagramWebURL = URL(string: "https://instagram.com/workkapp")!
    
    
}
