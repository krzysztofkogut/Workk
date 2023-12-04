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
    var workingHours: Double = 0.0
    var animate: Bool = false
}

extension Date {
    func updateHour(value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: value, minute: 0, second: 0, of: self) ?? .now
    }
}

var sample_analytics: [SiteView] = [
    SiteView(day: Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 1500),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -5, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 500),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -4, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 1900),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -3, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 2300),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -2, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 5000),
    SiteView(day: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!, moneyEarned: 11000),
    SiteView(day: Calendar.current.startOfDay(for: Date()), moneyEarned: 1000)
]
