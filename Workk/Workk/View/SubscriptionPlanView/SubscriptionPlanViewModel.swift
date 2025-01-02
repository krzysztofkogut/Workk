//
//  SubscriptionPlanViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 25/10/2023.
//

import Foundation

enum SubscriptionPlanViewModel: Int, CaseIterable {
    case month
    case year
    case forLife

    var title: String {
        switch self {
        case .month:
            return "monthly_subscription_title".localized
        case .year:
            return "yearly_subscription_title".localized
        case .forLife:
            return "for_life_title".localized
        }
    }

    var description: String {
        switch self {
        case .month:
            return "3.99$ " + "for_month_title".localized
        case .year:
            return "29.99$ " + "for_year_title".localized
        case .forLife:
            return  "for_life_description".localized + " 99.99$"
        }
    }
    
    var price: Float {
        switch self {
        case .month:
            3.99
        case .year:
            29.99
        case .forLife:
            99.99
        }
    }
}
