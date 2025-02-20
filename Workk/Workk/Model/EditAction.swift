//
//  EditAction.swift
//  Workk
//
//  Created by Krzysztof Kogut on 10/02/2025.
//

import Foundation

enum EditAction: String, CaseIterable {
    case delete
    case addSingle
    case addMultiple
    case markAsPaid
    case markAsUnpaid
    
    var title: String {
        switch self {
        case .delete:
            "delete_title".localized
        case .addSingle:
            "add_title".localized
        case .addMultiple:
            "add_multiple_title".localized
        case .markAsPaid:
            "mark_as_paid_title".localized
        case .markAsUnpaid:
            "mark_as_unpaid_title".localized
        }
    }
    
    var longTitle: String {
        switch self {
        case .delete:
            "delete_title".localized
        case .addSingle:
            "add_work_time_long_title".localized
        case .addMultiple:
            "add_multiple_long_title".localized
        case .markAsPaid:
            "mark_as_paid_long_title".localized
        case .markAsUnpaid:
            "mark_as_unpaid_long_title".localized
        }
    }
}
