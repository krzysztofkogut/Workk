//
//  HomeViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 05/11/2023.
//

import Combine
import Foundation

protocol HomeViewModelProtocol where Self: ObservableObject {
    var selectedFilter: PeriodFilter { get set }
    var currentTime: Time { get set }
    var timeReciver: Publishers.Autoconnect<Timer.TimerPublisher> { get set }
    var currentDateString: String { get }
    
    func updateCurrentTime()
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var selectedFilter: PeriodFilter = .day
    @Published var currentTime = Time(hour: 0, min: 0, sec: 0)
    @Published var timeReciver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @Published var stopwatch: Stopwatch = Stopwatch()
    
    private let router: HomeRouter
    
    private let currentDateFormatter = DateFormatter(dateFormat: "dd MMMM, yyyy", calendar: Calendar.current)
    private let currentDayFormatter = DateFormatter(dateFormat: "EEEE", calendar: Calendar.current)
    private let currentWeekFormatter = DateFormatter(dateFormat: "dd MMMM", calendar: Calendar.current)
    private let currentMonthFormatter = DateFormatter(dateFormat: "MMMM", calendar: Calendar.current)
    private let currentYearFormatter = DateFormatter(dateFormat: "yyyy", calendar: Calendar.current)

    var currentDateString: String {
        currentDateFormatter.string(from: Date())
    }
    
    var currentDayString: String {
        currentDayFormatter.string(from: Date())
    }
    
    var currentWeekString: String {
        guard let weekBoundry = Calendar(identifier: .iso8601).currentWeekBoundary(),
              let startOfWeek = weekBoundry.startOfWeek,
              let endOfWeek = weekBoundry.endOfWeek else {
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
    }
    
    func updateCurrentTime() {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: Date())
        let min = calendar.component(.minute, from: Date())
        let sec = calendar.component(.second, from: Date())
        
        currentTime = Time(hour: hour, min: min, sec: sec)
    }
    
    func showSubscriptionPlan() {
        router.showSubscriptionPlan()
    }
}
