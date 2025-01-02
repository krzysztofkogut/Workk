//
//  PaymentStatus.swift
//  Workk
//
//  Created by Krzysztof Kogut on 10/10/2024.
//

import Foundation

enum PaymentStatus: String, CaseIterable {
    case paid
    case unpaid

    var title: String {
        switch self {
        case .paid:
            return "paid_title".localized
        case .unpaid:
            return "unpaid_title".localized
        }
    }

    var isPaid: Bool {
        switch self {
        case .paid:
            return true
        case .unpaid:
            return false
        }
    }
}
