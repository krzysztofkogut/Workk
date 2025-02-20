//
//  StatsViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/05/2024.
//

import Combine
import SwiftUI

protocol StatsViewModelProtocol where Self: ObservableObject {
    var workkPremiumTitle: AttributedString { get }
    var selectedPeriodFilter: PeriodFilter { get set }
}

final class StatsViewModel: StatsViewModelProtocol {
    @Published var selectedPeriodFilter: PeriodFilter = .day
    @Published var selectedWorkName: String? = "all_title".localized
    @Published var selectedPaymentStatus: PaymentStatus = .paid
    @Published var selectedWorkStatus: WorkStatus = .all

    @Published var selectedWeek: Date = .init()
    @Published var selectedMonth: Date = .init()
    @Published var selectedYearForMonths: Date = .init()
    @Published var selectedYear: Date = .init()
    
    @Published var daysOfWeek: [Date] = []
    @Published var weeksOfMonth: [Date] = []
    @Published var monthsOfYear: [Date] = []
    @Published var periodOf5Years: [Date] = []
    
    @Published var daySiteViews: [SiteView] = []
    @Published var weekSiteViews: [SiteView] = []
    @Published var monthSiteViews: [SiteView] = []
    @Published var yearSiteViews: [SiteView] = []
    
    @Published var weekFilters: Set<PeriodFilter> = [.day, .week]
    @Published var monthFilters: Set<PeriodFilter> = [.day, .week, .month]
    @Published var yearFilters: Set<PeriodFilter> = [.day, .week, .month, .year]
    
    
    var daysOfCurrentWeek: [Date] = Calendar(identifier: .iso8601).daysOfWeek()
    let daysInWeek = 7
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("try_workk_premium_title".localized)
        string.font = .latoRegular(size: 14)
        
        if let range = string.range(of: "workk_title".localized) {
            string[range].font = .nunitoBlack(size: 14)
        }
        
        return string
    }
    
    var isDataEmpty: Bool {
        switch selectedPeriodFilter {
        case .day:
            daysOfWeek
                .compactMap { chartData(for: $0) }
                .isEmpty
        case .week:
            weeksOfMonth
                .compactMap { chartData(for: $0) }
                .isEmpty
        case .month:
            monthsOfYear
                .compactMap { chartData(for: $0) }
                .isEmpty
        case .year:
            periodOf5Years
                .compactMap { chartData(for: $0) }
                .isEmpty
        }
    }
    
    var moneyEarned: Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .map { $0.moneyEarned }
                .reduce(0, +)
        }
    }
    
    var workingHours: Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .map { $0.workingHours }
                .reduce(0, +)
        }
    }
    
    var currentSiteViews: [SiteView] {
        switch selectedPeriodFilter {
        case .day:
            daySiteViews
        case .week:
            weekSiteViews
        case .month:
            monthSiteViews
        case .year:
            yearSiteViews
        }
    }
    
    init() {
        daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedWeek)
        weeksOfMonth = Calendar(identifier: .iso8601).weeksOfMonth(for: selectedMonth)
        monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: selectedYearForMonths)
        periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: selectedYear)
    }
    
    private func backwardToLastWeek() {
        if let lastWeek = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: -1, to: selectedWeek) {
            selectedWeek = lastWeek
        }
    }
    
    private func forwardToNextWeek() {
        if let nextWeek = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: 1, to: selectedWeek) {
            selectedWeek = nextWeek
        }
    }
    
    private func backwardToLastMonth() {
        if let lastMonth = Calendar(identifier: .iso8601).date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = lastMonth
        }
    }
    
    private func forwardToNextMonth() {
        if let nextMonth = Calendar(identifier: .iso8601).date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = nextMonth
        }
    }
    
    private func backwardToLastYearForMonths() {
        if let lastYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: -1, to: selectedYearForMonths) {
            selectedYearForMonths = lastYear
        }
    }
    
    private func forwardToNextYearForMonths() {
        if let nextYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: 1, to: selectedYearForMonths) {
            selectedYearForMonths = nextYear
        }
    }
    
    private func backwardToLastYear() {
        if let lastYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: -1, to: selectedYear) {
            selectedYear = lastYear
        }
    }
    
    private func forwardToNextYear() {
        if let nextYear = Calendar(identifier: .iso8601).date(byAdding: .year, value: 1, to: selectedYear) {
            selectedYear = nextYear
        }
    }
    
    func reloadSiteViews(works: FetchedResults<Work>) {
        daySiteViews = generateDaySiteViews(works: works)
        weekSiteViews = generateWeekSiteViews(works: works)
        monthSiteViews = generateMonthsOfYearSiteViews(works: works)
        yearSiteViews = generateYearSiteViews(works: works)
    }
    
    func chartData(for date: Date) -> SiteView? {
        switch selectedPeriodFilter {
        case .day:
            daySiteViews.first { $0.day.isSameDay(date: date) }
        case .week:
            weekSiteViews.first { $0.day.isSameWeek(date: date) }
        case .month:
            monthSiteViews.first { $0.day.isSameMonth(date: date) }
        case .year:
            yearSiteViews.first { $0.day.isSameYear(date: date) }
        }
    }
    
    func generateDaySiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "all_title".localized ? $0.job?.name == selectedWorkName : true }
            .filter { $0.periodType == PeriodFilter.day.rawValue }
        
        let groupedByDay = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfDay() })
        
        let siteViews: [SiteView] = groupedByDay.map { day, worksForDay in
            let totalMoneyEarned = worksForDay.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForDay.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        return siteViews.sorted { $0.day < $1.day }
    }
    
    func generateWeekSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "all_title".localized ? $0.job?.name == selectedWorkName : true }
            .filter { weekFilters.contains(PeriodFilter(rawValue: $0.periodType) ?? .week) }
        
        let groupedByDay = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfWeek() })
        
        let siteViews: [SiteView] = groupedByDay.map { day, worksForWeek in
            let totalMoneyEarned = worksForWeek.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForWeek.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        return siteViews.sorted { $0.day < $1.day }
    }
    
    func generateMonthsOfYearSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "all_title".localized ? $0.job?.name == selectedWorkName : true }
            .filter { monthFilters.contains(PeriodFilter(rawValue: $0.periodType) ?? .week) }
        
        let groupedByMonth = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfMonth() })
        
        let siteViews: [SiteView] = groupedByMonth.map { day, worksForMonth in
            let totalMoneyEarned = worksForMonth.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForMonth.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        return siteViews.sorted { $0.day < $1.day }
    }
    
    func generateYearSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "all_title".localized ? $0.job?.name == selectedWorkName : true }
            .filter { yearFilters.contains(PeriodFilter(rawValue: $0.periodType) ?? .week) }
        
        let groupedByYear = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfYear() })
        
        let siteViews: [SiteView] = groupedByYear.map { day, worksForYear in
            let totalMoneyEarned = worksForYear.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForYear.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        return siteViews.sorted { $0.day < $1.day }
    }
    
    func maxForMoney() -> Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .max { $1.moneyEarned > $0.moneyEarned }?
                .moneyEarned ?? 0.0
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .max { $1.moneyEarned > $0.moneyEarned }?
                .moneyEarned ?? 0.0
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .max { $1.moneyEarned > $0.moneyEarned }?
                .moneyEarned ?? 0.0
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.moneyEarned
                }
        }
    }
    
    func maxForHours() -> Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .max { $1.workingHours > $0.workingHours }?
                .workingHours ?? 0.0
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .max { $1.workingHours > $0.workingHours }?
                .workingHours ?? 0.0
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .max { $1.workingHours > $0.workingHours }?
                .workingHours ?? 0.0
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.workingHours
                }
        }
    }
    
    func moneyEarned(for date: Date) -> Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .map { $0.moneyEarned }
                .reduce(0, +)
        }
    }
    
    func workingHours(for date: Date) -> Float {
        switch selectedPeriodFilter {
        case .day:
            return daySiteViews
                .filter { $0.day.isSameWeek(date: selectedWeek) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .week:
            return weekSiteViews
                .filter { weekSiteView in
                    weeksOfMonth.contains { $0.isSameWeek(date: weekSiteView.day) }
                }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: selectedYearForMonths) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .year:
            return yearSiteViews
                .filter { siteView in
                    periodOf5Years.contains { periodDate in
                        siteView.day.isSameYear(date: periodDate)
                    }
                }
                .map { $0.workingHours }
                .reduce(0, +)
        }
    }
    
    func cancelAnimation() {
        switch selectedPeriodFilter {
        case .day:
            for (index, _) in daySiteViews.enumerated() {
                daySiteViews[index].animate = true
            }
        case .week:
            for (index, _) in weekSiteViews.enumerated() {
                weekSiteViews[index].animate = true
            }
        case .month:
            for (index, _) in monthSiteViews.enumerated() {
                monthSiteViews[index].animate = true
            }
        case .year:
            for (index, _) in yearSiteViews.enumerated() {
                yearSiteViews[index].animate = true
            }
        }
    }
    
    func animateChart(fromChange: Bool = false) {
        switch selectedPeriodFilter {
        case .day:
            for (index, _) in daySiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) { [weak self] in
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        self?.daySiteViews[index].animate = true
                    }
                }
            }
        case .week:
            for (index, _) in weekSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) { [weak self] in
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        self?.weekSiteViews[index].animate = true
                    }
                }
            }
        case .month:
            for (index, _) in monthSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) { [weak self] in
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        self?.monthSiteViews[index].animate = true
                    }
                }
            }
        case .year:
            for (index, _) in yearSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) { [weak self] in
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        self?.yearSiteViews[index].animate = true
                    }
                }
            }
        }
    }
    
    func showToday() {
        switch selectedPeriodFilter {
        case .day:
            selectedWeek = .now
            daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedWeek)
        case .week:
            selectedMonth = .now
            weeksOfMonth = Calendar(identifier: .iso8601).weeksOfMonth(for: selectedMonth)
        case .month:
            selectedYearForMonths = .now
            monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: selectedYearForMonths)
        case .year:
            selectedYear = .now
            periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: selectedYear)
        }
    }
    
    func isToday() -> Bool {
        switch selectedPeriodFilter {
        case .day:
            selectedWeek.isThisWeek()
        case .week:
            selectedMonth.isThisMonth()
        case .month:
            selectedYearForMonths.isThisYear()
        case .year:
            selectedYear.isThisYear()
        }
    }
    
    func backwardAction() {
        switch selectedPeriodFilter {
        case .day:
            backwardToLastWeek()
            daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedWeek)
        case .week:
            backwardToLastMonth()
            weeksOfMonth = Calendar(identifier: .iso8601).weeksOfMonth(for: selectedMonth)
        case .month:
            backwardToLastYearForMonths()
            monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: selectedYearForMonths)
        case .year:
            backwardToLastYear()
            periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: selectedYear)
        }
    }
    
    func forwardAction() {
        switch selectedPeriodFilter {
        case .day:
            forwardToNextWeek()
            daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: selectedWeek)
        case .week:
            forwardToNextMonth()
            weeksOfMonth = Calendar(identifier: .iso8601).weeksOfMonth(for: selectedMonth)
        case .month:
            forwardToNextYearForMonths()
            monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: selectedYearForMonths)
        case .year:
            forwardToNextYear()
            periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: selectedYear)
        }
    }
}
