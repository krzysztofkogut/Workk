//
//  SiteView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct SiteView: Identifiable {
    var id = UUID().uuidString
    var day: Date
    var moneyEarned: Double
    var workingHours: Double
    var animate: Bool = false
}

extension Date {
    func updateHour(value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: value, minute: 0, second: 0, of: self) ?? .now
    }
}

var sample_analytics: [SiteView] = [
    SiteView(day: Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 1500,
             workingHours: 8),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -5, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 500,
             workingHours: 3),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -4, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 5000,
             workingHours: 13),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -3, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 1900,
             workingHours: 5),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -2, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 2300,
             workingHours: 4),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 11000,
             workingHours: 1),
    SiteView(day: Calendar.current.startOfDay(for: Date()),
             moneyEarned: 1000,
             workingHours: 10),
    SiteView(day: Calendar.current.date(byAdding: .day, value: 20, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 1500,
             workingHours: 8),
    SiteView(day: Calendar.current.date(byAdding: .day, value: 60, to: Calendar.current.startOfDay(for: Date()))!,
             moneyEarned: 4000,
             workingHours: 20),
]
