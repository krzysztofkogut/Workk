//
//  WorkData.swift
//  Workk
//
//  Created by Krzysztof Kogut on 16/01/2025.
//

import Foundation

struct WorkData {
    let id: UUID?
    let startDate: Date
    let endDate: Date
    let hourlyRate: Float
    let task: String?
    let project: String?
    let note: String?
    let moneyEarned: Float
    let hoursWorked: Float
    let periodType: String
    let isPaid: Bool
    let jobID: UUID?
}
