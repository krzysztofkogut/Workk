//
//  Date+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/02/2024.
//

import Foundation

extension Date {
    typealias WeekBoundaryString = (startOfWeekDay: String,
                                    startOfWeekMonth: String,
                                    endOfWeekDay: String,
                                    endOfWeekMonth: String)
    
    var currentDateString: String {
        let currentDateFormatter = DateFormatter(dateFormat: "dd MMMM, yyyy", calendar: Calendar.current)
        return currentDateFormatter.string(from: self)
    }
    
    var currentDayString: String {
        let currentDayFormatter = DateFormatter(dateFormat: "EEEE", calendar: Calendar.current)
        return currentDayFormatter.string(from: self)
    }
    
    var currentDayShortString: String {
        let currentDayShortFormatter = DateFormatter(dateFormat: "EE", calendar: Calendar.current)
        return currentDayShortFormatter.string(from: self)
    }
    
    var currentDayNumberString: String {
        let currentDayNumberFormatter = DateFormatter(dateFormat: "d", calendar: Calendar.current)
        return currentDayNumberFormatter.string(from: self)
    }
    
    var currentWeekString: String {
        guard let weekBoundry = Calendar(identifier: .iso8601).weekBoundary(for: self),
              let startOfWeek = weekBoundry.startOfWeek,
              let endOfWeek = weekBoundry.endOfWeek else {
            return ""
        }
        
        let currentWeekFormatter = DateFormatter(dateFormat: "dd MMM", calendar: Calendar.current)
        
        return currentWeekFormatter.string(from: startOfWeek) + " - " + currentWeekFormatter.string(from: endOfWeek)
    }
    
    var currentWeekBoundryString: WeekBoundaryString {
        guard let weekBoundry = Calendar(identifier: .iso8601).weekBoundary(for: self),
              let startOfWeek = weekBoundry.startOfWeek,
              let endOfWeek = weekBoundry.endOfWeek else {
            return ("", "", "", "")
        }
        
        let currentWeekDayFormatter = DateFormatter(dateFormat: "dd", calendar: Calendar.current)
        let currentWeekMonthFormatter = DateFormatter(dateFormat: "MMM", calendar: Calendar.current)
        
        return (currentWeekDayFormatter.string(from: startOfWeek), 
                currentWeekMonthFormatter.string(from: startOfWeek),
                currentWeekDayFormatter.string(from: endOfWeek),
                currentWeekMonthFormatter.string(from: endOfWeek))
    }
    
    var currentMonthString: String {
        let currentMonthFormatter = DateFormatter()
        currentMonthFormatter.locale = Locale(identifier: "pl")
        currentMonthFormatter.formattingContext = .standalone
        currentMonthFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        currentMonthFormatter.calendar = Calendar.current
        
        return currentMonthFormatter.string(from: self)
    }
    
    var currentYearString: String {
        let currentYearFormatter = DateFormatter(dateFormat: "yyyy", calendar: Calendar.current)
        return currentYearFormatter.string(from: self)
    }
    
    func isToday() -> Bool {
        Calendar(identifier: .iso8601).isDateInToday(self)
    }
    
    func isThisWeek() -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func isThisMonth() -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func isThisYear() -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    func isSameDay(date: Date) -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: date, toGranularity: .day)
    }
    
    func isSameWeek(date: Date) -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    func isSameMonth(date: Date) -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isSameYear(date: Date) -> Bool {
        Calendar(identifier: .iso8601).isDate(self, equalTo: date, toGranularity: .year)
    }
    
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}
