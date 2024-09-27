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
    
    @State var selectedPeriodFilter: PeriodFilter = .week
    @State var selectedWorkFilter: String? = "All"
    @State var showAddNewWorkView: Bool = false
    @State var sampleAnalytics: [SiteView] = sample_analytics
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
    
    private var moneyEarned: Double {
        switch selectedPeriodFilter {
        case .week:
            return sampleAnalytics
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        default:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: viewModel.selectedYear) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        }
    }
    
    private var workingHours: Double {
        switch selectedPeriodFilter {
        case .week:
            return sampleAnalytics
                .filter { $0.day.isSameWeek(date: viewModel.selectedWeek) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: viewModel.selectedYearForMonths) }
                .map { $0.workingHours }
                .reduce(0, +)
        default:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: viewModel.selectedYear) }
                .map { $0.workingHours }
                .reduce(0, +)
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                PeriodDropDownPicker(selection: $selectedPeriodFilter,
                                     options: [.week, .month, .year],
                               backgroundColor: .white)
                Spacer()
                
                DropDownPicker(selection: $selectedWorkFilter,
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
                    Text(workingHours(for: currentActiveHoursItem.day).stringFormat + " h")
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
        .onChange(of: selectedPeriodFilter) { newValue in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            sampleAnalytics = sample_analytics
            animateChart(fromChange: true)
        }
        .onChange(of: datePropertiesHash) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            sampleAnalytics = sample_analytics
            animateChart(fromChange: true)
        }
    }
    
    @ViewBuilder
    func AnimatedMoneyChart() -> some View {
        Chart {
            switch selectedPeriodFilter {
            case .week:
                ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                    let chartData = sampleAnalytics.first { $0.day.isSameDay(date: dayOfWeek) }
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
                    let chartData = sampleAnalytics.first { $0.day.isSameMonth(date: monthOfYear) }
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
                    let chartData = sampleAnalytics.first { $0.day.isSameYear(date: year) }
                    
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
        .chartYScale(domain: [0, maxForPeriod() + 300])
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 2))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedPeriodFilter.calendarComponent)) { date in
                AxisValueLabel(format: selectedPeriodFilter.dateFormat, centered: true)
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = sampleAnalytics.first(where: { 
                                calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                calendar.component(selectedPeriodFilter.calendarComponent, from: date) }) {
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
                                    if let currentItem = sampleAnalytics.first(where: { 
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: date) }) {
                                        self.currentActiveMoneyItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(height: 120)
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
                    let chartData = sampleAnalytics.first { $0.day.isSameDay(date: dayOfWeek) }
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
                    let chartData = SiteView(day: monthOfYear,
                                            moneyEarned: moneyEarned(for: monthOfYear),
                                            workingHours: workingHours(for: monthOfYear)) // to think about
                    
                    if let currentActiveHoursItem, currentActiveHoursItem.id == chartData.id {
                        BarMark(
                            x: .value("Month", currentActiveHoursItem.day, unit: .month),
                            y: .value("Hours", currentActiveHoursItem.workingHours)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else { //if let chartData {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Hours", chartData.workingHours)
                        )
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                    } //else {
//                        BarMark(
//                            x: .value("Month", monthOfYear, unit: .month),
//                            y: .value("Hours", 0)
//                        )
//                    }
                }
            default:
                ForEach(periodOf5Years, id: \.self) { year in
                    let chartData = sampleAnalytics.first { $0.day.isSameYear(date: year) }
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
        .chartYScale(domain: [0, maxForHours() + 8])
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 2))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedPeriodFilter.calendarComponent)) { date in
                AxisValueLabel(format: selectedPeriodFilter.dateFormat, centered: true)
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = sampleAnalytics.first(where: {
                                calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                calendar.component(selectedPeriodFilter.calendarComponent, from: date) }) {
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
                                    if let currentItem = sampleAnalytics.first(where: {
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                        calendar.component(selectedPeriodFilter.calendarComponent, from: date) }) {
                                        self.currentActiveHoursItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(height: 120)
        .onAppear {
            animateChart()
        }
    }
    
    func animateChart(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
    
    private func maxForPeriod() -> Double {
        switch selectedPeriodFilter {
        case .week:
//            return sampleAnalytics.max { $1.moneyEarned > $0.moneyEarned }?.moneyEarned ?? 0
            return sampleAnalytics
                .filter { $0.day.isThisWeek() }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.moneyEarned
                }
        case .month:
            return sampleAnalytics
                .filter { $0.day.isThisYear() }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.moneyEarned
                }
        default:
            return sampleAnalytics.reduce(0) { partialResult, siteView in
                partialResult + siteView.moneyEarned
            }
        }
    }
    
    private func maxForHours() -> Double {
        switch selectedPeriodFilter {
        case .week:
//            return sampleAnalytics.max { $1.workingHours > $0.workingHours }?.workingHours ?? 0
            return sampleAnalytics
                .filter { $0.day.isThisWeek() }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.workingHours
                }
        case .month:
            return sampleAnalytics
                .filter { $0.day.isThisYear() }
                .reduce(0) { partialResult, siteView in
                    partialResult + siteView.workingHours
                }
        default:
            return sampleAnalytics.reduce(0) { partialResult, siteView in
                partialResult + siteView.workingHours
            }
        }
    }
    
    private func moneyEarned(for date: Date) -> Double {
        switch selectedPeriodFilter {
        case .week:
            return sampleAnalytics
                .filter { $0.day.isSameWeek(date: date) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        case .month:
            return sampleAnalytics
                .filter { $0.day.isSameMonth(date: date) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        default:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: date) }
                .map { $0.moneyEarned }
                .reduce(0, +)
        }
    }
    
    private func workingHours(for date: Date) -> Double {
        switch selectedPeriodFilter {
        case .week:
            return sampleAnalytics
                .filter { $0.day.isSameWeek(date: date) }
                .map { $0.workingHours }
                .reduce(0, +)
        case .month:
            return sampleAnalytics
                .filter { $0.day.isSameMonth(date: date) }
                .map { $0.workingHours }
                .reduce(0, +)
        default:
            return sampleAnalytics
                .filter { $0.day.isSameYear(date: date) }
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
            viewModel.forwardToNextWeek()
            daysOfWeek = Calendar(identifier: .iso8601).daysOfWeek(for: viewModel.selectedWeek)
        case .month:
            viewModel.forwardToNextYearForMonths()
            monthsOfYear = Calendar(identifier: .iso8601).monthsOfYear(for: viewModel.selectedYearForMonths)
        default:
            viewModel.forwardToNextYear()
            periodOf5Years = Calendar(identifier: .iso8601).periodOf5Years(for: viewModel.selectedYear)
        }
    }
}

#Preview {
    StatsView()
}
