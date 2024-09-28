//
//  StatsViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/05/2024.
//

import Combine
import SwiftUI

protocol StatsViewModelProtocol where Self: ObservableObject {
    var selectedFilter: PeriodFilter { get set }
}

final class StatsViewModel: StatsViewModelProtocol {
    @Published var selectedFilter: PeriodFilter = .day

    @Published var selectedDay: Date = .init()
    @Published var selectedWeek: Date = .init()
    @Published var selectedYearForMonths: Date = .init()
    @Published var selectedYear: Date = .init()
    
    var daysOfCurrentWeek: [Date] = Calendar(identifier: .iso8601).daysOfWeek()
    let daysInWeek = 7
    
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
    
    func backwardToLastYearForMonths() {
        if let lastMonth = Calendar(identifier: .iso8601).date(byAdding: .year, value: -1, to: selectedYearForMonths) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedYearForMonths = lastMonth
            }
        }
    }
    
    func forwardToNextYearForMonths() {
        if let nextMonth = Calendar(identifier: .iso8601).date(byAdding: .year, value: 1, to: selectedYearForMonths) {
            withAnimation(.smooth(duration: 0.4)) {
                selectedYearForMonths = nextMonth
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
