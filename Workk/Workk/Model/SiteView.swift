//
//  SiteView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct SiteView: Identifiable, Equatable {
    var id = UUID().uuidString
    var day: Date
    var moneyEarned: Float
    var workingHours: Float
    var animate: Bool = false
    
    init(id: String = UUID().uuidString, day: Date, moneyEarned: Float, workingHours: Float, animate: Bool = false) {
        self.id = id
        self.day = day
        self.moneyEarned = moneyEarned
        self.workingHours = workingHours
        self.animate = animate
    }
    
    init(work: Work) {
        self.day = work.startDate
        self.moneyEarned = work.moneyEarned
        self.workingHours = work.hoursWorked
    }
}

extension Date {
    func updateHour(value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: value, minute: 0, second: 0, of: self) ?? .now
    }
}
