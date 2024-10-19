//
//  PaymentStatus.swift
//  Workk
//
//  Created by Krzysztof Kogut on 10/10/2024.
//

import Foundation
import SwiftUI

enum PaymentStatus: String, CaseIterable {
    case paid
    case unpaid

    var title: String {
        switch self {
        case .paid:
            return "Paid"
        case .unpaid:
            return "Unpaid"
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
