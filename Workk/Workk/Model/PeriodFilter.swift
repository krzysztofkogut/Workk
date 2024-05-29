//
//  HomeFilterViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import Foundation
import SwiftUI

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
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    
    var dateFormat: Date.FormatStyle {
        switch self {
        case .day:
            return .dateTime.day(.defaultDigits)
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.month(.abbreviated)
        case .year:
            return .dateTime.year(.defaultDigits)
        }
    }
}
