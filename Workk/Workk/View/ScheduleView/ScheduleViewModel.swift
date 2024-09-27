//
//  ScheduleViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/03/2024.
//

import Combine
import SwiftUI

protocol ScheduleViewModelProtocol where Self: ObservableObject {
    var selectedFilter: PeriodFilter { get set }

}

final class ScheduleViewModel: ScheduleViewModelProtocol {
    @Published var selectedFilter: PeriodFilter = .day

    @Published var selectedDay: Date = Date()
    @Published var selectedWeek: Date = Date()
    @Published var selectedMonth: Date = Date()
    @Published var selectedYear: Date = Date()
    
    var daysOfCurrentWeek: [Date] = Calendar(identifier: .iso8601).daysOfWeek()
    let daysInWeek = 7
    
    private let router: ScheduleRouter
    
    init(router: ScheduleRouter) {
        self.router = router
    }
    
    func showAddWorkTimeView(selectedWork: Binding<Work?>,
                             selectedFilter: Binding<PeriodFilter>,
                             selectedWorkName: Binding<String?>) {
        router.showAddWorkTimeView(selectedWork: selectedWork,
                                   selectedFilter: selectedFilter,
                                   selectedWorkName: selectedWorkName)
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
