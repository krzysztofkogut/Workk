//
//  StatsView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import Charts
import Resolver
import SwiftUI

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: StatsViewModel = Resolver.resolve()
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.id, ascending: true)]
    ) private var works: FetchedResults<Work>
    
    @State var selectedPeriodFilter: PeriodFilter = .week
    @State var selectedWorkName: String? = "All"
    @State var showAddNewWorkView: Bool = false
    
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var weekSiteViews: [SiteView] = []
    @State var monthSiteViews: [SiteView] = []
    @State var yearSiteViews: [SiteView] = []
    
    @State var moneyYScale: Float = 0.0
    @State var hoursYScale: Float = 0.0
    
    @State var currentActiveMoneyItem: SiteView?
    @State var currentActiveHoursItem: SiteView?
    @State var daysOfWeek: [Date] = []
    @State var monthsOfYear: [Date] = []
    @State var periodOf5Years: [Date] = []
    
    private let calendar = Calendar(identifier: .iso8601)
    
    init() {
        let viewModel = Resolver.resolve(StatsViewModel.self)
        _viewModel = ObservedObject(initialValue: viewModel)
        
        _daysOfWeek = State(initialValue: Calendar(identifier: .iso8601).daysOfWeek(for: viewModel.selectedWeek))
        _monthsOfYear = State(initialValue: Calendar(identifier: .iso8601).monthsOfYear(for: viewModel.selectedYearForMonths))
        _periodOf5Years = State(initialValue: Calendar(identifier: .iso8601).periodOf5Years(for: viewModel.selectedYear))
    }
    
    private var datePropertiesHash: Int {
        var hasher = Hasher()
        hasher.combine(daysOfWeek.map(\.hashValue).reduce(0, ^))
        hasher.combine(monthsOfYear.map(\.hashValue).reduce(0, ^))
        hasher.combine(periodOf5Years.map(\.hashValue).reduce(0, ^))
        return hasher.finalize()
    }
    
    private var moneyEarned: Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        default:
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
    
    private var workingHours: Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.workingHours }
                .reduce(0, +)
        default:
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
    
    private var currentSiteViews: [SiteView] {
        switch selectedPeriodFilter {
        case .week:
            weekSiteViews
        case .month:
            monthSiteViews
        default:
            yearSiteViews
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                PeriodDropDownPicker(selection: $selectedPeriodFilter,
                                     options: [.week, .month, .year],
                                     backgroundColor: .white)
                Spacer()
                
                DropDownPicker(selection: $selectedWorkName,
                               addNewOption: $showAddNewWorkView,
                               hint: "All",
                               state: .trailing,
                               options: ["All"] + jobs.compactMap { $0.name },
                               backgroundColor: .white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .zIndex(1001)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Money earned")
                        .font(.nunitoBold(size: 24))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                if let currentActiveMoneyItem = currentActiveMoneyItem {
                    Text(currentActiveMoneyItem.moneyEarned.stringFormat + " USD")
                        .font(.latoBold(size: 20))
                } else {
                    Text(moneyEarned.stringFormat + " USD")
                        .font(.latoBold(size: 20))
                }
                
                AnimatedMoneyChart()
            }
            .padding(24)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Hours worked")
                        .font(.nunitoBold(size: 24))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                if let currentActiveHoursItem = currentActiveHoursItem {
                    Text(currentActiveHoursItem.workingHours.stringFormat + " h")
                        .font(.latoBold(size: 20))
                } else {
                    Text(workingHours.stringFormat + " h")
                        .font(.latoBold(size: 20))
                }
                
                AnimatedHoursChart()
            }
            .padding(24)
            
            Spacer()
                        
            HStack(spacing: 0) {
                Button(action: backwardAction) {
                    Image(systemName: "chevron.left")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                }
                .padding(.leading, 24)
                
                Spacer()
                
                switch selectedPeriodFilter {
                case .week:
                    WeekCard(isSelected: true, week: viewModel.selectedWeek)
                case .month:
                    YearCard(isSelected: true, year: viewModel.selectedYearForMonths)
                default:
                    YearCard(isSelected: true, year: viewModel.selectedYear)
                }
                
                Spacer()
                
                Button(action: forwardAction) {
                    Image(systemName: "chevron.right")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 24)
            }
            .frame(height: 62)
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear {
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
            weekSiteViews = generateWeekSiteViews(works: works)
            monthSiteViews = generateMonthsOfYearSiteViews(works: works)
            yearSiteViews = generateYearSiteViews(works: works)
        }
        .onChange(of: weekSiteViews) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: monthSiteViews) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: yearSiteViews) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: viewModel.selectedWeek) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: viewModel.selectedYearForMonths) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: viewModel.selectedYear) { _ in
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
        }
        .onChange(of: selectedWorkName) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
            weekSiteViews = generateWeekSiteViews(works: works)
            monthSiteViews = generateMonthsOfYearSiteViews(works: works)
            yearSiteViews = generateYearSiteViews(works: works)
            animateChart(fromChange: true)
        }
        .onChange(of: selectedPeriodFilter) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
            weekSiteViews = generateWeekSiteViews(works: works)
            monthSiteViews = generateMonthsOfYearSiteViews(works: works)
            yearSiteViews = generateYearSiteViews(works: works)
            animateChart(fromChange: true)
        }
        .onChange(of: datePropertiesHash) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            moneyYScale = maxForMoney()
            hoursYScale = maxForHours()
            weekSiteViews = generateWeekSiteViews(works: works)
            monthSiteViews = generateMonthsOfYearSiteViews(works: works)
            yearSiteViews = generateYearSiteViews(works: works)
            animateChart(fromChange: true)
        }
    }
    
    @ViewBuilder
    func AnimatedMoneyChart() -> some View {
        Chart {
            switch selectedPeriodFilter {
            case .week:
                ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                    let chartData = weekSiteViews.first { $0.day.isSameDay(date: dayOfWeek) }
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        BarMark(
                            x: .value("Day", currentActiveMoneyItem.day, unit: .day),
                            y: .value("Money", currentActiveMoneyItem.moneyEarned)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Day", dayOfWeek, unit: .day),
                            y: .value("Money", chartData.animate ? chartData.moneyEarned : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Day", dayOfWeek, unit: .day),
                            y: .value("Money", 0)
                        )
                    }
                }
            case .month:
                ForEach(monthsOfYear, id: \.self) { monthOfYear in
                    let chartData = monthSiteViews.first { $0.day.isSameMonth(date: monthOfYear) }
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        BarMark(
                            x: .value("Month", currentActiveMoneyItem.day, unit: .month),
                            y: .value("Money", currentActiveMoneyItem.moneyEarned)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Money", chartData.animate ? chartData.moneyEarned : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Money", 0)
                        )
                    }
                }
            default:
                ForEach(periodOf5Years, id: \.self) { year in
                    let chartData = yearSiteViews.first { $0.day.isSameYear(date: year) }
                    
//                    let moneyEarned = sampleAnalytics
//                        .filter { $0.day.isSameYear(date: year) }
//                        .reduce(0) { result, element in
//                            result + element
//                        }
                        
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        BarMark(
                            x: .value("Year", currentActiveMoneyItem.day, unit: .year),
                            y: .value("Money", currentActiveMoneyItem.moneyEarned)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Year", year, unit: .year),
                            y: .value("Money", chartData.animate ? chartData.moneyEarned : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Year", year, unit: .year),
                            y: .value("Money", 0)
                        )
                    }
                }
            }
        }
        .chartYScale(domain: [0, 1.4 * moneyYScale])
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 2))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedPeriodFilter.calendarComponent)) { _ in
                AxisValueLabel(format: selectedPeriodFilter.dateFormat, centered: true)
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = currentSiteViews.first(where: {
                                calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                    calendar.component(selectedPeriodFilter.calendarComponent, from: date)
                            }) {
                                self.currentActiveMoneyItem = (self.currentActiveMoneyItem == nil ||
                                    self.currentActiveMoneyItem?.id != currentItem.id) ? currentItem : nil
                            }
                        }
                    })
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    if let currentItem = currentSiteViews.first(where: {
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                            calendar.component(selectedPeriodFilter.calendarComponent, from: date)
                                    }) {
                                        self.currentActiveMoneyItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(maxHeight: .infinity)
        .onAppear {
            animateChart()
        }
    }
    
    @ViewBuilder
    func AnimatedHoursChart() -> some View {
        Chart {
            switch selectedPeriodFilter {
            case .week:
                ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                    let chartData = weekSiteViews.first { $0.day.isSameDay(date: dayOfWeek) }
                    if let currentActiveHoursItem, currentActiveHoursItem.id == chartData?.id {
                        BarMark(
                            x: .value("Day", currentActiveHoursItem.day, unit: .day),
                            y: .value("Hours", currentActiveHoursItem.workingHours)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Day", dayOfWeek, unit: .day),
                            y: .value("Hours", chartData.animate ? chartData.workingHours : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Day", dayOfWeek, unit: .day),
                            y: .value("Hours", 0)
                        )
                    }
                }
            case .month:
                ForEach(monthsOfYear, id: \.self) { monthOfYear in
                    let chartData = monthSiteViews.first { $0.day.isSameMonth(date: monthOfYear) }
                    if let currentActiveHoursItem, currentActiveHoursItem.id == chartData?.id {
                        BarMark(
                            x: .value("Month", currentActiveHoursItem.day, unit: .month),
                            y: .value("Hours", currentActiveHoursItem.workingHours)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Hours", chartData.animate ? chartData.workingHours : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Hours", 0)
                        )
                    }
                }
            default:
                ForEach(periodOf5Years, id: \.self) { year in
                    let chartData = yearSiteViews.first { $0.day.isSameYear(date: year) }
                    if let currentActiveHoursItem, currentActiveHoursItem.id == chartData?.id {
                        BarMark(
                            x: .value("Year", currentActiveHoursItem.day, unit: .year),
                            y: .value("Money", currentActiveHoursItem.workingHours)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Year", year, unit: .year),
                            y: .value("Money", chartData.animate ? chartData.workingHours : 0)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Year", year, unit: .year),
                            y: .value("Money", 0)
                        )
                    }
                }
            }
        }
        .chartYScale(domain: [0, 1.4 * hoursYScale])
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 2))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedPeriodFilter.calendarComponent)) { _ in
                AxisValueLabel(format: selectedPeriodFilter.dateFormat, centered: true)
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = currentSiteViews.first(where: {
                                calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                    calendar.component(selectedPeriodFilter.calendarComponent, from: date)
                            }) {
                                self.currentActiveHoursItem = (self.currentActiveHoursItem == nil ||
                                    self.currentActiveHoursItem?.id != currentItem.id) ? currentItem : nil
                            }
                        }
                    })
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    if let currentItem = currentSiteViews.first(where: {
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                            calendar.component(selectedPeriodFilter.calendarComponent, from: date)
                                    }) {
                                        self.currentActiveHoursItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(maxHeight: .infinity)
        .onAppear {
            animateChart()
        }
    }
    
    func animateChart(fromChange: Bool = false) {
        switch selectedPeriodFilter {
        case .week:
            for (index, _) in weekSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        weekSiteViews[index].animate = true
                    }
                }
            }
        case .month:
            for (index, _) in monthSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        monthSiteViews[index].animate = true
                    }
                }
            }
        default:
            for (index, _) in yearSiteViews.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                    withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                        yearSiteViews[index].animate = true
                    }
                }
            }
        }
    }
    
    private func maxForMoney() -> Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .max { $1.moneyEarned > $0.moneyEarned }?
                .moneyEarned ?? 0.0
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .max { $1.moneyEarned > $0.moneyEarned }?
                .moneyEarned ?? 0.0
        default:
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
    
    private func maxForHours() -> Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .max { $1.workingHours > $0.workingHours }?
                .workingHours ?? 0.0
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .max { $1.workingHours > $0.workingHours }?
                .workingHours ?? 0.0
        default:
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
    
    private func moneyEarned(for date: Date) -> Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        default:
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
    
    private func workingHours(for date: Date) -> Float {
        switch selectedPeriodFilter {
        case .week:
            return weekSiteViews
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return monthSiteViews
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.workingHours }
                .reduce(0, +)
        default:
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
    
    private func backwardAction() {
        switch selectedPeriodFilter {
        case .week:
            viewModel.backwardToLastWeek()
            daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: viewModel.selectedWeek)
        case .month:
            viewModel.backwardToLastYearForMonths()
            monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: viewModel.selectedYearForMonths)
        default:
            viewModel.backwardToLastYear()
            periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: viewModel.selectedYear)
        }
    }
    
    private func forwardAction() {
        switch selectedPeriodFilter {
        case .week:
            withAnimation(.smooth(duration: 0.4)) {
                viewModel.forwardToNextWeek()
                daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: viewModel.selectedWeek)
            }
        case .month:
            withAnimation(.smooth(duration: 0.4)) {
                viewModel.forwardToNextYearForMonths()
                monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: viewModel.selectedYearForMonths)
            }
        default:
            withAnimation(.smooth(duration: 0.4)) {
                viewModel.forwardToNextYear()
                periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: viewModel.selectedYear)
            }
        }
    }
    
    private func generateWeekSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
            .filter { $0.periodType == PeriodFilter.day.rawValue }
        
        // Group works by the start of each day (ignoring time components)
        let groupedByDay = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfDay() })
        
        // For each day, sum the moneyEarned and hoursWorked
        let siteViews: [SiteView] = groupedByDay.map { day, worksForDay in
            let totalMoneyEarned = worksForDay.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForDay.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        // Optional: Sort the array by day if needed
        return siteViews.sorted { $0.day < $1.day }
    }
    
    private func generateMonthsOfYearSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works
            .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
            .filter {
                $0.periodType == PeriodFilter.day.rawValue ||
                    $0.periodType == PeriodFilter.week.rawValue ||
                    $0.periodType == PeriodFilter.month.rawValue
            }
        
        // Group works by the start of each day (ignoring time components)
        let groupedByMonth = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfMonth() })
        
        // For each day, sum the moneyEarned and hoursWorked
        let siteViews: [SiteView] = groupedByMonth.map { day, worksForMonth in
            let totalMoneyEarned = worksForMonth.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForMonth.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        // Optional: Sort the array by day if needed
        return siteViews.sorted { $0.day < $1.day }
    }
    
    private func generateYearSiteViews(works: FetchedResults<Work>) -> [SiteView] {
        let filteredWorks = works.filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
        
        // Group works by the start of each day (ignoring time components)
        let groupedByYear = Dictionary(grouping: filteredWorks, by: { $0.startDate.startOfYear() })
        
        // For each day, sum the moneyEarned and hoursWorked
        let siteViews: [SiteView] = groupedByYear.map { day, worksForYear in
            let totalMoneyEarned = worksForYear.reduce(0) { $0 + $1.moneyEarned }
            let totalHoursWorked = worksForYear.reduce(0) { $0 + $1.hoursWorked }
            
            return SiteView(day: day, moneyEarned: totalMoneyEarned, workingHours: totalHoursWorked)
        }
        
        // Optional: Sort the array by day if needed
        return siteViews.sorted { $0.day < $1.day }
    }
}

#Preview {
    StatsView()
}
