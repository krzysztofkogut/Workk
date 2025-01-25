//
//  HomeViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 05/11/2023.
//

import Combine
import SwiftUI

protocol HomeViewModelProtocol where Self: ObservableObject {
    var goalTitle: AttributedString { get }
    
    var currentTime: Time { get set }
    var timeReciver: Publishers.Autoconnect<Timer.TimerPublisher> { get set }
    var currentDateString: String { get }
    
    func updateCurrentTime()
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var currentTime = Time(hour: 0, min: 0, sec: 0)
    @Published var timeReciver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @Published var stopwatch: Stopwatch = .init()
    
    @Published var selectedDay: Date = .init()
    @Published var selectedWeek: Date = .init()
    @Published var selectedMonth: Date = .init()
    @Published var selectedYear: Date = .init()
    
    @Published var daysOfCurrentWeek: [Date] = Calendar(identifier: .iso8601).daysOfWeek()
    
    private let router: HomeRouter
    
    private let currentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter
    }()
    
    private let currentDayFormatter = DateFormatter(dateFormat: "EEEE", calendar: Calendar.current)
    private let currentDayShortFormatter = DateFormatter(dateFormat: "EE", calendar: Calendar.current)
    private let currentDayNumberFormatter = DateFormatter(dateFormat: "dd", calendar: Calendar.current)
    private let currentWeekFormatter = DateFormatter(dateFormat: "dd MMM", calendar: Calendar.current)
    private let currentMonthFormatter = DateFormatter(dateFormat: "MMMM", calendar: Calendar.current)
    private let currentYearFormatter = DateFormatter(dateFormat: "yyyy", calendar: Calendar.current)
        
    var goalTitle: AttributedString {
        var string = AttributedString("goal_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var currentDateString: String {
        currentDateFormatter.string(from: Date())
    }
    
    var currentDayString: String {
        currentDayFormatter.string(from: Date())
    }
    
    var currentDayShortString: String {
        currentDayShortFormatter.string(from: Date())
    }
    
    var currentDayNumberString: String {
        currentDayNumberFormatter.string(from: Date())
    }
    
    var currentWeekString: String {
        guard let weekBoundry = Calendar(identifier: .iso8601).currentWeekBoundary(),
              let startOfWeek = weekBoundry.startOfWeek,
              let endOfWeek = weekBoundry.endOfWeek
        else {
            return ""
        }
        
        return currentWeekFormatter.string(from: startOfWeek) + " - " + currentWeekFormatter.string(from: endOfWeek)
    }
    
    var currentMonthString: String {
        currentMonthFormatter.string(from: Date())
    }
    
    var currentYearString: String {
        currentYearFormatter.string(from: Date())
    }
    
    init(router: HomeRouter) {
        self.router = router
        daysOfCurrentWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedDay)
    }
    
    func updateCurrentTime() {
        let calendar = Calendar.current
        let localeRegion = Locale.current.region?.identifier ?? ""
        
        let hour = calendar.component(.hour, from: Date())
        let min = calendar.component(.minute, from: Date())
        let sec = calendar.component(.second, from: Date())
        
        let is12HourFormat = Constants.monthFirstLocales.contains(localeRegion)
        
        let formattedHour = is12HourFormat ? (hour % 12 == 0 ? 12 : hour % 12) : hour
        let amPmMarker = is12HourFormat ? (hour < 12 ? "AM" : "PM") : ""
        
        currentTime = Time(hour: formattedHour, min: min, sec: sec, amPm: amPmMarker)
    }
    
    func showSubscriptionPlanView() {
        router.showSubscriptionPlanView()
    }
    
    func selectToday() {
        selectedDay = .now
        daysOfCurrentWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedDay)
    }
    
    func backwardToLastDaysWeek() {
        if let firstWeekDay = daysOfCurrentWeek.first, let lastWeekStartDay = Calendar(identifier: .iso8601).date(byAdding: .day, value: -7, to: firstWeekDay) {
            withAnimation(.smooth(duration: 0.4)) {
                daysOfCurrentWeek = Calendar(identifier: .iso8601).daysOfWeek(for: lastWeekStartDay)
                selectedDay = lastWeekStartDay
                
                if let day = daysOfCurrentWeek.first(where: { $0.isToday() }) {
                    selectedDay = day
                }
            }
        }
    }
    
    func forwardToNextDaysWeek() {
        if let lastWeekDay = daysOfCurrentWeek.last, let nextWeekStartDay = Calendar(identifier: .iso8601).date(byAdding: .day, value: 1, to: lastWeekDay) {
            withAnimation(.smooth(duration: 0.4)) {
                daysOfCurrentWeek = Calendar(identifier: .iso8601).daysOfWeek(for: nextWeekStartDay)
                selectedDay = nextWeekStartDay
                
                if let day = daysOfCurrentWeek.first(where: { $0.isToday() }) {
                    selectedDay = day
                }
            }
        }
    }
    
    func backwardToLastWeek() {
        if let lastWeek = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: -1, to: selectedWeek) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedWeek = lastWeek
            }
        }
    }
    
    func forwardToNextWeek() {
        if let nextWeek = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: 1, to: selectedWeek) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedWeek = nextWeek
            }
        }
    }
    
    func backwardToLastMonth() {
        if let lastMonth = Calendar(identifier: .iso8601).date(byAdding: .month, value: -1, to: selectedMonth) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedMonth = lastMonth
            }
        }
    }
    
    func forwardToNextMonth() {
        if let nextMonth = Calendar(identifier: .iso8601).date(byAdding: .month, value: 1, to: selectedMonth) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedMonth = nextMonth
            }
        }
    }
    
    func backwardToLastYear() {
        if let lastYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: -1, to: selectedYear) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedYear = lastYear
            }
        }
    }
    
    func forwardToNextYear() {
        if let nextYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: 1, to: selectedYear) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedYear = nextYear
            }
        }
    }
}
