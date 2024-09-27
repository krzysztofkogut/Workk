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
            return "Monthly"
        case .year:
            return "Yearly"
        case .forLife:
            return "For life"
        }
    }

    var description: String {
        switch self {
        case .month:
            return "3.99$ for month"
        case .year:
            return "29.99$ for year"
        case .forLife:
            return "Have Workk premium forever for one time payment 99.99$"
        }
    }
}
