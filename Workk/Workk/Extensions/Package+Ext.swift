//
//  Package+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/01/2025.
//

import Foundation
import RevenueCat
import StoreKit

extension Package {
    var terms: String {
        if let intro = self.storeProduct.introductoryDiscount {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle) free trial"
            } else {
                return "\(self.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}
