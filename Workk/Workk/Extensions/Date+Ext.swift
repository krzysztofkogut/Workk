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
        let currentDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.locale = Locale.current
            formatter.dateStyle = .long
            return formatter
        }()
        
        return currentDateFormatter.string(from: self)
    }
    
    var currentShortDateString: String {
        let currentDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.locale = Locale.current
            formatter.dateStyle = .short
            return formatter
        }()
        
        return currentDateFormatter.string(from: self)
    }
    
    var dayPickerDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let localeRegion = Locale.current.region?.identifier ?? ""
        
        if Constants.monthFirstLocales.contains(localeRegion) {
            formatter.dateFormat = "MMM d yyyy, h:mm a"
        } else {
            formatter.dateFormat = "d MMM yyyy, HH:mm"
        }
        return formatter.string(from: self)
    }
    
    var dayPickerOnlyDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let localeRegion = Locale.current.region?.identifier ?? ""
        
        if Constants.monthFirstLocales.contains(localeRegion) {
            formatter.dateFormat = "MMM d yyyy"
        } else {
            formatter.dateFormat = "d MMM yyyy"
        }
        return formatter.string(from: self)
    }
    
    var dayPickerOnlyHourString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let localeRegion = Locale.current.region?.identifier ?? ""
        
        if Constants.monthFirstLocales.contains(localeRegion) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: self)
    }
    
    var currentHourString: String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let localeRegion = Locale.current.region?.identifier ?? ""
        
        if Constants.monthFirstLocales.contains(localeRegion) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: self)
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
              let endOfWeek = weekBoundry.endOfWeek
        else {
            return ""
        }
        
        let currentWeekFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.locale = Locale.current
            let localeRegion = Locale.current.region?.identifier ?? ""
            
            if Constants.monthFirstLocales.contains(localeRegion) {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "d MMM"
            }
 
            return formatter
        }()
        
        return currentWeekFormatter.string(from: startOfWeek) + " - " + currentWeekFormatter.string(from: endOfWeek)
    }
    
    var currentWeekScheduleString: String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: self) ?? self
        
        let currentWeekFormatter = DateFormatter(dateFormat: "d MMM", calendar: calendar)
        
        return "\(currentWeekFormatter.string(from: self)) - \(currentWeekFormatter.string(from: endOfWeek))"
    }
    
    var currentWeekStatsString: String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        
        let startOfWeek = adjustedStartOfWeek(for: self)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
        
        let currentWeekFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.locale = Locale.current
            let localeRegion = Locale.current.region?.identifier ?? ""
            
            if Constants.monthFirstLocales.contains(localeRegion) {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "d MMM"
            }

            return formatter
        }()
        
        return "\(currentWeekFormatter.string(from: startOfWeek))\n\(currentWeekFormatter.string(from: endOfWeek))"
    }
    
    func adjustedStartOfWeek(for date: Date) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        calendar.firstWeekday = 2 // Poniedziałek jako pierwszy dzień tygodnia

        // Oblicz dzień tygodnia dla daty (poniedziałek = 2, niedziela = 1)
        let weekday = calendar.component(.weekday, from: date)

        // Oblicz przesunięcie (jeśli to np. piątek, przesuń do najbliższego poniedziałku)
        let daysToNextMonday = (9 - weekday) % 7
        let adjustedStartOfWeek = calendar.date(byAdding: .day, value: daysToNextMonday, to: date)!

        return adjustedStartOfWeek
    }
    
    var currentWeekBoundryString: WeekBoundaryString {
        guard let weekBoundry = Calendar(identifier: .iso8601).weekBoundary(for: self),
              let startOfWeek = weekBoundry.startOfWeek,
              let endOfWeek = weekBoundry.endOfWeek
        else {
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
        currentMonthFormatter.formattingContext = .standalone
        currentMonthFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        currentMonthFormatter.calendar = Calendar.current
        
        return currentMonthFormatter.string(from: self)
    }
    
    var currentYearString: String {
        let currentYearFormatter = DateFormatter(dateFormat: "yyyy", calendar: Calendar.current)
        return currentYearFormatter.string(from: self)
    }
    
    var formatedWeekBoundary: String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        
        let startOfWeek = calendar.date(byAdding: .day, value: 1, to: self) ?? self
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        
        let startString = dateFormatter.string(from: startOfWeek)
        let endString = dateFormatter.string(from: endOfWeek)
        
        return "\(startString)\n\(endString)"
    }
    
    func isToday() -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDateInToday(self)
    }
    
    func isThisWeek() -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func isThisMonth() -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func isThisYear() -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    func isSameDay(date: Date) -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: date, toGranularity: .day)
    }
    
    func isSameWeek(date: Date) -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    func isSameMonth(date: Date) -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isSameYear(date: Date) -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.isDate(self, equalTo: date, toGranularity: .year)
    }
    
    func startOfDay() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.startOfDay(for: self)
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }
    
    func endOfWeek() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .weekOfYear, for: self)?.end ?? self
    }
    
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
    
    func startOfMonth() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .month, for: self)?.start ?? self
    }
    
    func endOfMonth() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .month, for: self)?.end ?? self
    }
    
    func startOfYear() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .year, for: self)?.start ?? self
    }
    
    func endOfYear() -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .year, for: self)?.end ?? self
    }
    
    func updatingYearMonthAndDay(from otherDate: Date) -> Date? {
        let calendar = Calendar(identifier: .iso8601)
        
        // Extract the current date components (hour, minute, second, etc.)
        var currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        // Extract the month and day from the other date
        let newDateComponents = calendar.dateComponents([.year, .month, .day], from: otherDate)
        
        // Update the current components with the new year, month and day
        currentComponents.year = newDateComponents.year
        currentComponents.month = newDateComponents.month
        currentComponents.day = newDateComponents.day
        
        // Return the new date by combining the updated components
        return calendar.date(from: currentComponents)
    }
    
    func timeDifference(to endDate: Date) -> String {
        // Calculate the difference between the two dates
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.hour, .minute, .second], from: self, to: endDate)

        // Format the result
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional // Shows 1h 2m 3s as 1:02:03
        formatter.zeroFormattingBehavior = .pad // Pads with zeros, like 01:02:03
        
        // Format the date components into a string
        if let formattedString = formatter.string(from: components) {
            return formattedString
        } else {
            return "Invalid date difference"
        }
    }
    
    func timeDifferenceInHours(to endDate: Date) -> Float {
        let timeInterval = endDate.timeIntervalSince(self) // Time interval in seconds
        let timeDifferenceInHours = Float(timeInterval.wholeSeconds) / 3600.0 // Convert seconds to hours
        return timeDifferenceInHours
    }
    
    func timeDifferenceInMinutes(to endDate: Date) -> Float {
        let timeInterval = endDate.timeIntervalSince(self) // Time interval in seconds
        return Float(timeInterval) / 60.0 // Convert seconds to minutes
    }
    
    func setDateAtSpecificHourAndMinute(hour: Int, minute: Int) -> Date? {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        // Use the current calendar and today's date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: self)

        // Combine today's date with the desired time
        return calendar.date(byAdding: components, to: today)
    }
}
