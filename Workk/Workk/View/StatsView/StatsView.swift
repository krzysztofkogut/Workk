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
    
    @Namespace private var filterAnimation
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: StatsViewModel = Resolver.resolve()
    @ObservedObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
        
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.id, ascending: true)],
        predicate: NSPredicate(format: "isPaid == TRUE")
    ) private var paidWorks: FetchedResults<Work>
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.id, ascending: true)],
        predicate: NSPredicate(format: "isPaid == FALSE")
    ) private var unpaidWorks: FetchedResults<Work>
    
    @State var selectedJob: Job? = nil
    
    @State private var showAddNewJobView: Bool = false
    @State private var showFilterView: Bool = false
    @State private var showSubscriptionPlanView: Bool = false
    @State private var filtersWidthDict: [PaymentStatus: CGFloat] = [:]
    @State private var moneyYScale: Float = 0.0
    @State private var hoursYScale: Float = 0.0
    @State private var currentActiveMoneyItem: SiteView?
    @State private var currentActiveHoursItem: SiteView?
    
    @State private var stopAnimation: Bool = false
    
    private let calendar = Calendar(identifier: .iso8601)
    private let smallDeviceWidth: CGFloat = 375
    
    private var datePropertiesHash: Int {
        var hasher = Hasher()
        hasher.combine(viewModel.daysOfWeek.map(\.hashValue).reduce(0, ^))
        hasher.combine(viewModel.weeksOfMonth.map(\.hashValue).reduce(0, ^))
        hasher.combine(viewModel.monthsOfYear.map(\.hashValue).reduce(0, ^))
        hasher.combine(viewModel.periodOf5Years.map(\.hashValue).reduce(0, ^))
        return hasher.finalize()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                DropDownPicker(selection: $viewModel.selectedWorkName,
                               addNewOption: $showAddNewJobView,
                               showSubscriptionPlan: $showSubscriptionPlanView,
                               hint: "all_title".localized,
                               options: ["all_title".localized] + jobs.compactMap { $0.name },
                               backgroundColor: .whiteTheme,
                               maxWidth: UIScreen.main.bounds.width > smallDeviceWidth ? 180 : 160)
                    .zIndex(2001)
                    .padding(.leading,
                             viewModel.selectedPeriodFilter.title.widthOfString(usingFont: .latoBlack(size: 18)) + 70)
                
                HStack(spacing: 0) {
                    PeriodDropDownPicker(selection: $viewModel.selectedPeriodFilter,
                                         options: [.day, .week, .month, .year],
                                         backgroundColor: .whiteTheme)
                    
                    Spacer()
                    
                    Button {
                        showFilterView = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(.blackWhite)
                            .font(.title)
                    }
                }
                .zIndex(3001)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .zIndex(3001)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("money_earned_title".localized)
                        .font(.nunitoBold(size: 24))
                        .foregroundColor(.blackWhite)
                    
                    Spacer()
                }
                
                if let currentActiveMoneyItem = currentActiveMoneyItem {
                    Text(currentActiveMoneyItem.moneyEarned.stringFormat + " " + currencyIdentifier.uppercased())
                        .font(.latoBold(size: 20))
                        .foregroundColor(.blackWhite)
                } else {
                    Text(viewModel.moneyEarned.stringFormat + " " + currencyIdentifier.uppercased())
                        .font(.latoBold(size: 20))
                        .foregroundColor(.blackWhite)
                }
                
                animatedMoneyChart()
            }
            .padding(24)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("hours_worked_stats_title".localized)
                        .font(.nunitoBold(size: 24))
                        .foregroundColor(.blackWhite)
                    
                    Spacer()
                }
                
                if let currentActiveHoursItem = currentActiveHoursItem {
                    Text(currentActiveHoursItem.workingHours.stringFormat + " h")
                        .font(.latoBold(size: 20))
                        .foregroundColor(.blackWhite)
                } else {
                    Text(viewModel.workingHours.stringFormat + " h")
                        .font(.latoBold(size: 20))
                        .foregroundColor(.blackWhite)
                }
                
                animatedHoursChart()
            }
            .padding(24)
            
            Spacer()
            
            paymentStatusFilterBar
                        
            HStack(spacing: 0) {
                Button {
                    stopAnimation = true
                    viewModel.backwardAction()
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blackWhite)
                }
                .padding(.leading, 24)
                
                Spacer()
                
                switch viewModel.selectedPeriodFilter {
                case .day:
                    WeekCard(isSelected: true, week: viewModel.selectedWeek)
                case .week:
                    MonthCard(isSelected: true, month: viewModel.selectedMonth)
                case .month:
                    YearCard(isSelected: true, year: viewModel.selectedYearForMonths)
                case .year:
                    YearCard(isSelected: true, year: viewModel.selectedYear)
                }
                
                Spacer()
                
                Button {
                    stopAnimation = true
                    viewModel.forwardAction()
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blackWhite)
                }
                .padding(.trailing, 24)
            }
            .frame(height: 62)
            .background(.whiteTheme)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .onChange(of: jobs.count) { _ in
            let isSelectedWorkNameMissing = jobs.allSatisfy { $0.name != viewModel.selectedWorkName }
                
            if isSelectedWorkNameMissing {
                viewModel.selectedWorkName = "all_title".localized
            }
        }
        .onAppear {
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .onChange(of: viewModel.selectedWeek) { _ in
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .onChange(of: viewModel.selectedMonth) { _ in
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .onChange(of: viewModel.selectedYearForMonths) { _ in
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .onChange(of: viewModel.selectedYear) { _ in
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .onChange(of: viewModel.selectedWorkName) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: viewModel.selectedPeriodFilter) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: viewModel.selectedPaymentStatus) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: viewModel.weekFilters) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: viewModel.monthFilters) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: viewModel.yearFilters) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            viewModel.reloadSiteViews(works: viewModel.selectedPaymentStatus.isPaid ? paidWorks : unpaidWorks)
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
            viewModel.animateChart(fromChange: true)
        }
        .onChange(of: datePropertiesHash) { _ in
            currentActiveMoneyItem = nil
            currentActiveHoursItem = nil
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
        .overlay(
            ZStack {
                Color.wildSand.opacity(0.9)
                    .ignoresSafeArea()
                    .blur(radius: 0, opaque: false)
                    
                VStack(spacing: 8) {
                    Text("premium_description".localized)
                        .font(.latoBlack(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .multilineTextAlignment(.center)
                        .padding([.top, .horizontal], 24)
                        
                    Text(viewModel.workkPremiumTitle)
                        .foregroundStyle(.whiteBlack)
                        .padding(.horizontal, 24)
                        
                    Button {
                        showSubscriptionPlanView = true
                    } label: {
                        Text("try_for_free_button_title".localized)
                            .font(.latoBlack(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(.wildSand, in: .rect(cornerRadius: 30))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(.blackWhite, in: .rect(cornerRadius: 12))
                .padding(16)
            }
            .hide(if: userSubscriptionViewModel.subscriptionActive)
        )
        .fullScreenCover(isPresented: $showAddNewJobView) {
            AddJobView(selectedJob: $selectedJob)
        }
        .fullScreenCover(isPresented: $showSubscriptionPlanView) {
            SubscriptionPlanView()
        }
        .sheet(isPresented: $showFilterView) {
            StatsFilterView(weekFilters: $viewModel.weekFilters,
                            monthFilters: $viewModel.monthFilters,
                            yearFilters: $viewModel.yearFilters)
                .background(.wildSand)
        }
    }
    
    var paymentStatusFilterBar: some View {
        HStack(spacing: 8) {
            ForEach(PaymentStatus.allCases, id: \.rawValue) { item in
                Text(item.title)
                    .font(.latoBold(size: 14))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .foregroundColor(viewModel.selectedPaymentStatus == item ? .whiteBlack : .blackWhite)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(viewModel.selectedPaymentStatus == item ? .blackWhite : .whiteTheme, in: .rect(cornerRadius: 18))
                    .onTapGesture {
                        self.viewModel.selectedPaymentStatus = item
                    }
            }
            
            Spacer()
                .hide(if: viewModel.isToday())
            
            Button {
                viewModel.showToday()
            } label: {
                Text("today_title".localized)
                    .font(.latoBold(size: 14))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.whiteBlack)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.blackWhite, in: .rect(cornerRadius: 18))
            }
            .hide(if: viewModel.isToday())
        }
        .animation(.easeInOut, value: viewModel.isToday())
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func animatedMoneyChart() -> some View {
        Chart {
            switch viewModel.selectedPeriodFilter {
            case .day:
                ForEach(viewModel.daysOfWeek, id: \.self) { dayOfWeek in
                    let chartData = viewModel.chartData(for: dayOfWeek)
                    
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        createSelectedBarMark(for: currentActiveMoneyItem)
                            .foregroundStyle(.blueRibbon)
                            .cornerRadius(4)
                    } else if let chartData {
                        createAnimatedBarMark(for: dayOfWeek, from: chartData)
                            .foregroundStyle(.blackWhite)
                            .cornerRadius(4)
                    } else {
                        createEmptyBarMark(for: dayOfWeek)
                    }
                }
            case .week:
                ForEach(viewModel.weeksOfMonth, id: \.self) { weekOfMonth in
                    let chartData = viewModel.chartData(for: weekOfMonth)
                    
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        createSelectedBarMark(for: currentActiveMoneyItem)
                            .foregroundStyle(.blueRibbon)
                            .cornerRadius(4)
                    } else if let chartData {
                        createAnimatedBarMark(for: weekOfMonth, from: chartData)
                            .foregroundStyle(.blackWhite)
                            .cornerRadius(4)
                    } else {
                        createEmptyBarMark(for: weekOfMonth)
                    }
                }
            case .month:
                ForEach(viewModel.monthsOfYear, id: \.self) { monthOfYear in
                    let chartData = viewModel.chartData(for: monthOfYear)
                    
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        createSelectedBarMark(for: currentActiveMoneyItem)
                            .foregroundStyle(.blueRibbon)
                            .cornerRadius(4)
                    } else if let chartData {
                        createAnimatedBarMark(for: monthOfYear, from: chartData)
                            .foregroundStyle(.blackWhite)
                            .cornerRadius(4)
                    } else {
                        createEmptyBarMark(for: monthOfYear)
                    }
                }
            case .year:
                ForEach(viewModel.periodOf5Years, id: \.self) { year in
                    let chartData = viewModel.chartData(for: year)
                                            
                    if let currentActiveMoneyItem, currentActiveMoneyItem.id == chartData?.id {
                        createSelectedBarMark(for: currentActiveMoneyItem)
                            .foregroundStyle(.blueRibbon)
                            .cornerRadius(4)
                    } else if let chartData {
                        createAnimatedBarMark(for: year, from: chartData)
                            .foregroundStyle(.blackWhite)
                            .cornerRadius(4)
                    } else {
                        createEmptyBarMark(for: year)
                    }
                }
            }
        }
        .chartYScale(domain: [0, 1.4 * moneyYScale])
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 2))
        }
        .chartXAxis {
            withTransaction(Transaction(animation: nil)) {
                AxisMarks(values: .stride(by: viewModel.selectedPeriodFilter.calendarComponent)) { value in
                    switch viewModel.selectedPeriodFilter {
                    case .week:
                        if let dateValue = value.as(Date.self) {
                            AxisValueLabel(centered: true) {
                                Text(dateValue.currentWeekStatsString)
                                    .multilineTextAlignment(.center)
                                    .transaction { $0.animation = nil }
                            }
                        }
                    default:
                        AxisValueLabel(format: viewModel.selectedPeriodFilter.dateFormat, centered: true)
                    }
                }
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = viewModel.currentSiteViews.first(where: {
                                calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                    calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: date)
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
                                    if let currentItem = viewModel.currentSiteViews.first(where: {
                                        calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                            calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: date)
                                    }) {
                                        self.currentActiveMoneyItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 70, maxHeight: .infinity)
        .onAppear {
            viewModel.animateChart()
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
    }
    
    @ViewBuilder
    func animatedHoursChart() -> some View {
        Chart {
            switch viewModel.selectedPeriodFilter {
            case .day:
                ForEach(viewModel.daysOfWeek, id: \.self) { dayOfWeek in
                    let chartData = viewModel.chartData(for: dayOfWeek)
                    
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
                        .foregroundStyle(.blackWhite)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Day", dayOfWeek, unit: .day),
                            y: .value("Hours", 0)
                        )
                    }
                }
            case .week:
                ForEach(viewModel.weeksOfMonth, id: \.self) { weekOfMonth in
                    let chartData = viewModel.chartData(for: weekOfMonth)
                    
                    if let currentActiveHoursItem, currentActiveHoursItem.id == chartData?.id {
                        BarMark(
                            x: .value("Week", weekOfMonth, unit: .weekOfYear),
                            y: .value("Hours", currentActiveHoursItem.workingHours)
                        )
                        .foregroundStyle(.blueRibbon)
                        .cornerRadius(4)
                    } else if let chartData {
                        BarMark(
                            x: .value("Week", weekOfMonth, unit: .weekOfYear),
                            y: .value("Hours", chartData.animate ? chartData.workingHours : 0)
                        )
                        .foregroundStyle(.blackWhite)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Week", weekOfMonth, unit: .weekOfYear),
                            y: .value("Hours", 0)
                        )
                    }
                }
            case .month:
                ForEach(viewModel.monthsOfYear, id: \.self) { monthOfYear in
                    let chartData = viewModel.chartData(for: monthOfYear)
                    
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
                        .foregroundStyle(.blackWhite)
                        .cornerRadius(4)
                    } else {
                        BarMark(
                            x: .value("Month", monthOfYear, unit: .month),
                            y: .value("Hours", 0)
                        )
                    }
                }
            default:
                ForEach(viewModel.periodOf5Years, id: \.self) { year in
                    let chartData = viewModel.chartData(for: year)
                    
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
                        .foregroundStyle(.blackWhite)
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
            AxisMarks(values: .stride(by: viewModel.selectedPeriodFilter.calendarComponent)) { value in
                switch viewModel.selectedPeriodFilter {
                case .week:
                    if let dateValue = value.as(Date.self) {
                        AxisValueLabel(centered: true) {
                            Text(dateValue.currentWeekStatsString)
                                .multilineTextAlignment(.center)
                        }
                    }
                default:
                    AxisValueLabel(format: viewModel.selectedPeriodFilter.dateFormat, centered: true)
                }
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .onTapGesture(perform: { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            let calendar = Calendar.current
                            if let currentItem = viewModel.currentSiteViews.first(where: {
                                calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                    calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: date)
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
                                    if let currentItem = viewModel.currentSiteViews.first(where: {
                                        calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: $0.day) ==
                                            calendar.component(viewModel.selectedPeriodFilter.calendarComponent, from: date)
                                    }) {
                                        self.currentActiveHoursItem = currentItem
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 16)
        })
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 70, maxHeight: .infinity)
        .onAppear {
            viewModel.animateChart()
            moneyYScale = viewModel.maxForMoney()
            hoursYScale = viewModel.maxForHours()
        }
    }
    
    private func createSelectedBarMark(for siteView: SiteView) -> BarMark {
        switch viewModel.selectedPeriodFilter {
        case .day:
            return BarMark(
                x: .value("Day", siteView.day, unit: .day),
                y: .value("Money", siteView.moneyEarned)
            )
        case .week:
            return BarMark(
                x: .value("Week", siteView.day, unit: .weekOfMonth),
                y: .value("Money", siteView.moneyEarned)
            )
        case .month:
            return BarMark(
                x: .value("Month", siteView.day, unit: .month),
                y: .value("Money", siteView.moneyEarned)
            )
        case .year:
            return BarMark(
                x: .value("Year", siteView.day, unit: .year),
                y: .value("Money", siteView.moneyEarned)
            )
        }
    }
    
    private func createAnimatedBarMark(for date: Date, from siteView: SiteView) -> BarMark {
        switch viewModel.selectedPeriodFilter {
        case .day:
            return BarMark(
                x: .value("Day", date, unit: .day),
                y: .value("Money", siteView.animate ? siteView.moneyEarned : 0)
            )
        case .week:
            return BarMark(
                x: .value("Week", date, unit: .weekOfMonth),
                y: .value("Money", siteView.animate ? siteView.moneyEarned : 0)
            )
        case .month:
            return BarMark(
                x: .value("Month", date, unit: .month),
                y: .value("Money", siteView.animate ? siteView.moneyEarned : 0)
            )
        case .year:
            return BarMark(
                x: .value("Year", date, unit: .year),
                y: .value("Money", siteView.animate ? siteView.moneyEarned : 0)
            )
        }
    }

    private func createEmptyBarMark(for date: Date) -> BarMark {
        switch viewModel.selectedPeriodFilter {
        case .day:
            return BarMark(
                x: .value("Day", date, unit: .day),
                y: .value("Money", 0)
            )
        case .week:
            return BarMark(
                x: .value("Week", date, unit: .weekOfMonth),
                y: .value("Money", 0)
            )
        case .month:
            return BarMark(
                x: .value("Month", date, unit: .month),
                y: .value("Money", 0)
            )
        case .year:
            return BarMark(
                x: .value("Year", date, unit: .year),
                y: .value("Money", 0)
            )
        }
    }
}

#Preview {
    StatsView()
}
