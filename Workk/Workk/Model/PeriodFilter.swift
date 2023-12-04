//
//  HomeFilterViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import Foundation

enum PeriodFilter: Int, CaseIterable {
    case day
    case week
    case month
    case year
    
    var title: String {
        switch self {
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
    
    var statsTitle: String {
        switch self {
        case .day:
            return "Today"
        case .week:
            return "This week"
        case .month:
            return "This month"
        case .year:
            return "This year"
        }
    }
}
