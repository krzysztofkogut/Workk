//
//  Calendar+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 09/01/2024.
//

import Foundation

extension Calendar {
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
    
    func currentWeekBoundary() -> WeekBoundary? {
        return weekBoundary(for: Date())
    }
        
    func daysOfWeek(for date: Date = Date()) -> [Date] {
        let dateComponents = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = self.date(from: dateComponents)!
        let startOfWeekNoon = self.date(bySettingHour: 12, minute: 0, second: 0, of: startOfWeek)!
        return (0...6).map { self.date(byAdding: .day, value: $0, to: startOfWeekNoon)! }
    }
    
    func monthsOfYear(for date: Date = Date()) -> [Date] {
        let dateComponents = self.dateComponents([.year], from: date)
        let startOfYear = self.date(from: dateComponents)!
        let startOfYearNoon = self.date(bySettingHour: 12, minute: 0, second: 0, of: startOfYear)!
        return (0...11).map { self.date(byAdding: .month, value: $0, to: startOfYearNoon)! }
    }
    
    func periodOf5Years(for date: Date = Date()) -> [Date] {
        let dateComponents = self.dateComponents([.year], from: date)
        let startOfYear = self.date(from: dateComponents)!
        let startOfYearNoon = self.date(bySettingHour: 12, minute: 0, second: 0, of: startOfYear)!
        return (-2...2).map { self.date(byAdding: .year, value: $0, to: startOfYearNoon)! }
    }
    
    func lastTwoWeeks(for date: Date = Date()) -> [Date] {
        (-1...0).map { self.date(byAdding: .weekOfYear, value: $0, to: date)! }.reversed()
    }
    
    func lastThreeMonths(for date: Date = Date()) -> [Date] {
        (-2...0).map { self.date(byAdding: .month, value: $0, to: date)! }.reversed()
    }
    
    func lastFourYears(for date: Date = Date()) -> [Date] {
        (-3...0).map { self.date(byAdding: .year, value: $0, to: date)! }.reversed()
    }
    
    func weekBoundary(for date: Date) -> WeekBoundary? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
    
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}
