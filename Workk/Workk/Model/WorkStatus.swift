//
//  WorkStatus.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/02/2025.
//

import Foundation

enum WorkStatus: String, CaseIterable {
    case all
    case paid
    case unpaid
    case regular
    case overtime

    var title: String {
        switch self {
        case .paid:
            return "paid_title".localized
        case .unpaid:
            return "unpaid_title".localized
        case .all:
            return "all_title".localized
        case .regular:
            return "regular_time_title".localized
        case .overtime:
            return "overtime_title".localized
        }
    }
}
