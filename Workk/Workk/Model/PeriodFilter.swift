//
//  HomeFilterViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import Foundation

enum PeriodFilter: String, CaseIterable {
    case day
    case week
    case month
    case year
    
    var title: String {
        switch self {
        case .day:
            return "day_title".localized
        case .week:
            return "week_title".localized
        case .month:
            return "month_title".localized
        case .year:
            return "year_title".localized
        }
    }
    
    var chartStride: Calendar.Component {
        switch self {
        case .day:
            return .day
        case .week:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    
    var dateFormat: Date.FormatStyle {
        switch self {
        case .day:
            return .dateTime.weekday(.abbreviated)
        case .week:
            return .dateTime.week(.defaultDigits)
        case .month:
            return .dateTime.month(.abbreviated)
        case .year:
            return .dateTime.year(.defaultDigits)
        }
    }
    
    var orderNumber: Int {
        switch self {
        case .day:
            1
        case .week:
            2
        case .month:
            3
        case .year:
            4
        }
    }
}
