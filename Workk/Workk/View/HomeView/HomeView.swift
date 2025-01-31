//
//  HomeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import ActivityKit
import AdmobSwiftUI
import Resolver
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.requestReview) private var requestReview
    
    @Namespace var filterAnimation
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @AppStorage("dailyMoneyGoal") private var dailyMoneyGoal: String = ""
    @AppStorage("weeklyMoneyGoal") private var weeklyMoneyGoal: String = ""
    @AppStorage("monthlyMoneyGoal") private var monthlyMoneyGoal: String = ""
    @AppStorage("yearlyMoneyGoal") private var yearlyMoneyGoal: String = ""
    
    @AppStorage("dailyHoursGoal") private var dailyHoursGoal: String = ""
    @AppStorage("weeklyHoursGoal") private var weeklyHoursGoal: String = ""
    @AppStorage("monthlyHoursGoal") private var monthlyHoursGoal: String = ""
    @AppStorage("yearlyHoursGoal") private var yearlyHoursGoal: String = ""

    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: HomeViewModel = Resolver.resolve()
    
    @StateObject private var adManager: InterstitialAdManager = Resolver.resolve()
    @ObservedObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()

    @StateObject private var nativeDayDetailsViewModel: NativeAdViewModel = .init(
        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
        requestInterval: 300)

    @StateObject private var nativeWeekDetailsViewModel: NativeAdViewModel = .init(
        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
        requestInterval: 300)

    @StateObject private var nativeMonthDetailsViewModel: NativeAdViewModel = .init(
        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
        requestInterval: 300)

    @StateObject private var nativeYearDetailsViewModel: NativeAdViewModel = .init(
        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
        requestInterval: 300)

    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>

    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)]
    ) private var works: FetchedResults<Work>

    @State private var selectedWork: Work? = nil
    @State private var selectedFilter: PeriodFilter = .day
    @State private var selectedFilterWidth: CGFloat = 0
    @State private var activity: Activity<WorkTimeStatusAttributes>? = nil
    
    @State private var dayMoneyProgressValue: CGFloat = 0
    @State private var weekMoneyProgressValue: CGFloat = 0
    @State private var monthMoneyProgressValue: CGFloat = 0
    @State private var yearMoneyProgressValue: CGFloat = 0
    @State private var dayHoursProgressValue: CGFloat = 0
    @State private var weekHoursProgressValue: CGFloat = 0
    @State private var monthHoursProgressValue: CGFloat = 0
    @State private var yearHoursProgressValue: CGFloat = 0
    
    @State private var isOvertime = false
    @State private var overtimePercentage: String = "150"
    
    @State private var timeReciver = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    @State private var countWorkTime = false
    @State private var pauseTimer = false
    
    @State private var selectedWorkName: String? = "all_title".localized
    @State private var selectedJob: Job? = nil
    @State private var selectedJobToAdd: Job? = nil
    
    @State private var showAddJobView: Bool = false
    @State private var showAddWorkTimeView: Bool = false
    @State private var showSubscriptionPlanView: Bool = false
    @State private var showProfileView: Bool = false
    @State private var showAlertSheet: Bool = false
    @State private var showAddedEntrySheet: Bool = false
    @State private var showAddedEntryDetails: Bool = false
    
    @State private var filtersWidthDict: [PeriodFilter: CGFloat] = [:]
    
    @State private var workTimeForNewEntry: String? = nil

    @State private var isDayDetailsBannerAdLoaded: Bool = false
    @State private var isWeekDetailsBannerAdLoaded: Bool = false
    @State private var isMonthDetailsBannerAdLoaded: Bool = false
    @State private var isYearDetailsBannerAdLoaded: Bool = false

    @State private var isProfileButtonSelected: Bool = false
    
    @State private var isDropDownError: Bool = false
    
    private let dayDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let weekDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let monthDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let yearDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    
    private let reviewThresholds: Set<Int> = [30, 100, 300]
    
    var overTimeMultiplier: Float {
        isOvertime ? (overtimePercentage.floatValue() / 100) : 1.0
    }
    
    var dayPaidMoney: Float {
        works
            .filter { $0.startDate.isSameDay(date: viewModel.selectedDay) && $0.isPaid && $0.periodType == "day" }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var dayUnpaidMoney: Float {
        works
            .filter { $0.startDate.isSameDay(date: viewModel.selectedDay) && !$0.isPaid && $0.periodType == "day" }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var weekPaidMoney: Float {
        works
            .filter { $0.startDate.isSameWeek(date: viewModel.selectedWeek) && $0.isPaid && ($0.periodType == "day" || $0.periodType == "week") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var weekUnpaidMoney: Float {
        works
            .filter { $0.startDate.isSameWeek(date: viewModel.selectedWeek) && !$0.isPaid && ($0.periodType == "day" || $0.periodType == "week") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var monthPaidMoney: Float {
        works
            .filter { $0.startDate.isSameMonth(date: viewModel.selectedMonth) && $0.isPaid && ($0.periodType == "day" || $0.periodType == "week" || $0.periodType == "month") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var monthUnpaidMoney: Float {
        works
            .filter { $0.startDate.isSameMonth(date: viewModel.selectedMonth) && !$0.isPaid && ($0.periodType == "day" || $0.periodType == "week" || $0.periodType == "month") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var yearPaidMoney: Float {
        works
            .filter { $0.startDate.isSameYear(date: viewModel.selectedYear) && $0.isPaid }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var yearUnpaidMoney: Float {
        works
            .filter { $0.startDate.isSameYear(date: viewModel.selectedYear) && !$0.isPaid }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.moneyEarned }
    }
    
    var dayHours: Float {
        works
            .filter { $0.startDate.isSameDay(date: viewModel.selectedDay) && $0.periodType == "day" }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.hoursWorked }
    }
    
    var weekHours: Float {
        works
            .filter { $0.startDate.isSameWeek(date: viewModel.selectedWeek) && ($0.periodType == "day" || $0.periodType == "week") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.hoursWorked }
    }
    
    var monthHours: Float {
        works
            .filter { $0.startDate.isSameMonth(date: viewModel.selectedMonth) && ($0.periodType == "day" || $0.periodType == "week" || $0.periodType == "month") }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.hoursWorked }
    }
    
    var yearHours: Float {
        works
            .filter { $0.startDate.isSameYear(date: viewModel.selectedYear) }
            .filter { $0.jobName == selectedWorkName || selectedWorkName == "all_title".localized }
            .reduce(0) { $0 + $1.hoursWorked }
    }
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
            VStack(spacing: 0) {
                HStack {
                    DropDownPicker(
                        selection: $selectedWorkName,
                        addNewOption: $showAddJobView,
                        showSubscriptionPlan: $showSubscriptionPlanView,
                        isError: $isDropDownError,
                        hint: "select_title".localized,
                        options: ["all_title".localized] + jobs.compactMap { $0.name },
                        backgroundColor: .wildSand,
                        maxWidth: 220)

                    Spacer()

                    Button {
                        isProfileButtonSelected.toggle()
                        showProfileView = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .addSymbolEffect(isSelected: isProfileButtonSelected)
                            .foregroundStyle(.blackWhite)
                            .font(.title)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .zIndex(1000)
                .background(
                    Color.whiteTheme
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                )

                headerActionsView
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.whiteTheme
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                UIApplication.shared.dismissKeyboard()
                            }
                    )
                    .clipShape(RoundedShape(corners: [.bottomLeft, .bottomRight]))

                detailsView
            }
            .background(
                Color.wildSand
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
            )
            .onAppear {
                if !userSubscriptionViewModel.subscriptionActive {
                    Task {
                        await adManager.loadAd()
                    }
                }
                
                Task {
                    await updateProgressBar()
                }
                
                withAnimation(.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                }
            }
            .onReceive(timeReciver) { _ in
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                }
            }
            .onChange(of: selectedWorkName) { newValue in
                Task {
                    await updateProgressBar()
                }
                
                if isDropDownError {
                    isDropDownError = newValue == "all_title".localized
                }
                
                selectedJob = jobs.first(where: { $0.name == newValue })
            }
            .onChange(of: viewModel.selectedDay) { _ in Task { await updateProgressBar() } }
            .onChange(of: viewModel.selectedWeek) { _ in Task { await updateProgressBar() } }
            .onChange(of: viewModel.selectedMonth) { _ in Task { await updateProgressBar() } }
            .onChange(of: viewModel.selectedYear) { _ in Task { await updateProgressBar() } }
            .onChange(of: selectedFilter) { _ in updateProgressBarInstant() }
            .onChange(of: dailyMoneyGoal) { _ in updateProgressBarInstant() }
            .onChange(of: dailyHoursGoal) { _ in updateProgressBarInstant() }
            .onChange(of: weeklyMoneyGoal) { _ in updateProgressBarInstant() }
            .onChange(of: weeklyHoursGoal) { _ in updateProgressBarInstant() }
            .onChange(of: monthlyMoneyGoal) { _ in updateProgressBarInstant() }
            .onChange(of: monthlyHoursGoal) { _ in updateProgressBarInstant() }
            .onChange(of: yearlyMoneyGoal) { _ in updateProgressBarInstant() }
            .onChange(of: yearlyHoursGoal) { _ in updateProgressBarInstant() }
            .onChange(of: overtimePercentage) { newValue in
                overtimePercentage = newValue.formatNumberInput()
            }
            .onChange(of: jobs.count) { _ in
                let isSelectedWorkNameMissing = jobs.allSatisfy { $0.name != selectedWorkName }
                    
                if isSelectedWorkNameMissing {
                    countWorkTime = false
                    viewModel.stopwatch.reset()
                    stopLiveActivityTimer()
                    selectedWorkName = "all_title".localized
                }
            }
            .onChange(of: works.count) { newValue in
                Task {
                    await updateProgressBar()
                }
                
                if reviewThresholds.contains(newValue) {
                    requestReview()
                }
            }
            .withHomeRoutes()
            .fullScreenCover(isPresented: $showAddJobView) {
                AddJobView(selectedJob: $selectedJobToAdd)
            }
            .fullScreenCover(isPresented: $showAddWorkTimeView, onDismiss: {
                selectedWork = nil
            }, content: {
                AddWorkTimeView(
                    addWorkTimePlace: .home,
                    selectedFilter: selectedFilter,
                    selectedWork: $selectedWork,
                    selectedWorkName: $selectedWorkName)
            })
            .fullScreenCover(isPresented: $showSubscriptionPlanView) {
                SubscriptionPlanView()
            }
            .fullScreenCover(isPresented: $showProfileView) {
                ProfileView()
                    .background(.wildSand)
            }
            .floatingBottomSheet(isPresented: $showAlertSheet) {
                SheetView(
                    title: "select_job_title".localized,
                    content: "select_job_description".localized,
                    button1: .init(
                        content: "ok_title".localized,
                        tint: .whiteBlack,
                        foreground: .blackWhite,
                        action: {
                            showAlertSheet = false
                        }))
                        .presentationDetents([.height(250)])
            }
            .floatingBottomSheet(isPresented: $showAddedEntrySheet, onDismiss: {
                if showAddedEntryDetails {
                    showAddWorkTimeView = true
                    showAddedEntryDetails = false
                }
                workTimeForNewEntry = nil
            }, content: {
                SheetView(
                    title: "saved_your_work_title".localized,
                    content: viewModel.currentDateString + " | " + (workTimeForNewEntry ?? ""),
                    button1: .init(
                        content: "ok_title".localized,
                        tint: .whiteBlack,
                        foreground: .blackWhite,
                        action: {
                            showAddedEntrySheet = false
                        }),
                    button2: .init(
                        content: "Details",
                        tint: .blackWhite,
                        foreground: .grayTheme,
                        action: {
                            showAddedEntrySheet = false
                            showAddedEntryDetails = true
                        }))
                        .presentationDetents([.height(300)])
            })
        }
    }
}

extension HomeView {
    var headerActionsView: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .center) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.stopwatch.hours)
                        .foregroundStyle(.blackWhite)
                    Text(":")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.stopwatch.minutes)
                        .foregroundStyle(.blackWhite)
                    RollingText(font: .latoLight(size: 16), value: $viewModel.stopwatch.seconds)
                        .foregroundStyle(.blackWhite)
                        .padding(.leading, 2)
                }
                .transition(.opacity)
                .padding(.leading, 24)
                .opacity(countWorkTime ? 1 : 0)

                HStack(alignment: viewModel.currentTime.amPm.isEmpty ? .firstTextBaseline : .lastTextBaseline,
                       spacing: 0)
                {
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.currentTime.hour)
                        .foregroundStyle(.blackWhite)
                    Text(":")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.currentTime.min)
                        .foregroundStyle(.blackWhite)
                    VStack {
                        Text(viewModel.currentTime.amPm)
                            .font(.latoBold(size: 16))
                            .hide(if: viewModel.currentTime.amPm.isEmpty)
                        
                        RollingText(font: .latoLight(size: 16), value: $viewModel.currentTime.sec)
                            .foregroundStyle(.blackWhite)
                    }
                    .padding(.leading, 2)
                }
                .transition(.opacity)
                .padding(.leading, viewModel.currentTime.amPm.isEmpty ?
                    ("00".widthOfString(usingFont: .latoLight(size: 16)) + 2) :
                    ("AM".widthOfString(usingFont: .latoBold(size: 16)) + 2))
                .opacity(countWorkTime ? 0 : 1)
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }

            Text(viewModel.currentDateString)
                .font(.latoRegular(size: 16))
                .foregroundStyle(.blackWhite)
                .padding(.bottom, 16)
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }

            addWorkTimeButtons
            
            nowEarnedMoneyView
                .padding(.top, 16)
                .hide(if: !countWorkTime)
        }
        .padding(.bottom, 16)
    }
    
    var nowEarnedMoneyView: some View {
        VStack(spacing: 2) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("earned_now_title".localized)
                    .font(.nunitoSemiBold(size: 16))
                    .foregroundStyle(.blackWhite)
                
                Text(
                    (overTimeMultiplier *
                        (selectedJob?.hourlyRate ?? 0.0) *
                        viewModel.stopwatch.elapsedTime.hoursFloat).formatFloatToString() +
                        " " + currencyIdentifier.uppercased())
                    .font(.latoBold(size: 18))
                    .foregroundStyle(.blackWhite)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.stopwatch.elapsedTime)
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
            
            Text((selectedJob?.hourlyRate ?? 0.0).formatFloatToString() + " " + currencyIdentifier.uppercased() + "/h")
                .font(.latoRegular(size: 14))
                .foregroundStyle(.blackWhite)
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            HStack(spacing: 4) {
                Spacer()
                
                Text("overtime_title".localized)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
                
                CustomToggle(isOn: $isOvertime)
                    .padding(.trailing, 4)
                
                HStack(spacing: 8) {
                    TextField("overtime_title".localized, text: $overtimePercentage)
                        .foregroundStyle(.blackWhite)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .padding(.leading, 16)
                        .padding(.vertical, 16)
                    
                    Text("%")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 16))
                        .padding(.trailing, 16)
                }
                .background(.wildSand, in: .rect(cornerRadius: 12))
                .hide(if: !isOvertime)
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
    }

    var addWorkTimeButtons: some View {
        HStack {
            Button {
                guard works.count < 500 || userSubscriptionViewModel.subscriptionActive else {
                    showSubscriptionPlanView = true
                    return
                }
                
                guard selectedWorkName != nil && selectedWorkName != "all_title".localized else {
                    showAlertSheet = true
                    isDropDownError = true
                    return
                }

                if countWorkTime {
                    pauseTimer.toggle()
                    viewModel.stopwatch.isRunning.toggle()
                    pauseTimer
                        ? stopLiveActivityTimer()
                        : startLiveActivityTimer(elapsedTime: viewModel.stopwatch.elapsedTime)
                } else {
                    withAnimation(.bouncy(duration: 0.6)) {
                        countWorkTime.toggle()
                    }

                    viewModel.stopwatch.isRunning = true
                    startLiveActivityTimer(elapsedTime: viewModel.stopwatch.elapsedTime)
                }
                
                if countWorkTime, !works.isEmpty, works.count.isMultiple(of: 3), !userSubscriptionViewModel.subscriptionActive {
                    showAd()
                }
            } label: {
                Text(countWorkTime ? (pauseTimer ? "start_title".localized : "stop_title".localized) : "measure_time_title".localized)
                    .font(.latoBold(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
                    .frame(width: countWorkTime ? 110 : 150, height: 44)
                    .modifier(FilledButton())
                    .background(.blackWhite)
                    .cornerRadius(24)
            }

            if countWorkTime {
                Button {
                    guard selectedWorkName != "all_title".localized else {
                        showAlertSheet = true
                        return
                    }
                    
                    showAddedEntrySheet = true
                    addItem()
                    workTimeForNewEntry = viewModel.stopwatch.elapsedTime.timeString
                    viewModel.stopwatch.reset()
                    stopLiveActivityTimer()

                    withAnimation(.bouncy(duration: 0.6)) {
                        countWorkTime = false
                        pauseTimer = false
                    }
                } label: {
                    Text("save_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.blackWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 8)
                        .frame(width: 110, height: 44)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.blackWhite, lineWidth: 4)
                }
                .cornerRadius(24)
            }

            Button {
                if countWorkTime {
                    stopLiveActivityTimer()

                    withAnimation(.bouncy(duration: 0.6)) {
                        countWorkTime = false
                        pauseTimer = false
                    }
                } else {
                    showAddWorkTimeView.toggle()
                }

                viewModel.stopwatch.reset()
                isOvertime = false
                selectedWork = nil
            } label: {
                Text(countWorkTime ? "reset_title".localized : "save_time_title".localized)
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.blackWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
                    .frame(width: countWorkTime ? 110 : 150, height: 44)
                    .background(.wildSand)
                    .cornerRadius(24)
            }
        }
    }

    var detailsView: some View {
        VStack(spacing: 0) {
            periodFilterBar
                .padding(.top, 4)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

            TabView(selection: $selectedFilter) {
                dayDetailsView
                    .tag(PeriodFilter.day)

                weekDetailsView
                    .tag(PeriodFilter.week)

                monthDetailsView
                    .tag(PeriodFilter.month)

                yearDetailsView
                    .tag(PeriodFilter.year)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.2), value: selectedFilter)
        }
        .background(.wildSand)
    }

    var dayDetailsView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: viewModel.backwardToLastDaysWeek) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.leading, 12)
                        .padding(.trailing, -8)
                        
                        DayPicker(selection: $viewModel.selectedDay, days: $viewModel.daysOfCurrentWeek)
                        
                        Button(action: viewModel.forwardToNextDaysWeek) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.leading, -8)
                        .padding(.trailing, 12)
                    }
                }
                .id("top")
                .frame(height: 62)
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, isDayDetailsBannerAdLoaded || userSubscriptionViewModel.subscriptionActive ? 2 : -16)
                
                ZStack {
                    Button {
                        showSubscriptionPlanView.toggle()
                    } label: {
                        Text("buy_subscription_title".localized)
                            .font(.nunitoBold(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.blueRibbon)
                    }
                    .padding(.horizontal, 2)
                    
                    Group {
                        BannerAd(isLoaded: $isDayDetailsBannerAdLoaded, unitID: dayDetailsBannerId)
                            .frame(height: 50)
                            .cornerRadius(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.whiteTheme, lineWidth: 3)
                            }
                            .padding(6)
                    }
                    .background(.whiteTheme)
                    .cornerRadius(12)
                    .opacity(isDayDetailsBannerAdLoaded ? 1 : 0)
                }
                .padding(.bottom, isDayDetailsBannerAdLoaded ? 2 : -16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("earned_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                            
                            Text(viewModel.selectedDay.currentDateString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                                        
                    VStack(spacing: 8) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("paid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundStyle(.blackWhite)
                            Spacer()
                            Text(dayPaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("unpaid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundStyle(.blackWhite)
                            Spacer()
                            Text(dayUnpaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("total_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundStyle(.blackWhite)
                            Spacer()
                            Text((dayPaidMoney + dayUnpaidMoney).formatFloatToString() +
                                " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !dailyMoneyGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $dayMoneyProgressValue)
                            .fixedSize(horizontal: false, vertical: false)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.dayMoneyProgressValue * 100) + "%")
                                .animation(nil, value: dayMoneyProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text((dailyMoneyGoal.floatValue() - (dayPaidMoney + dayUnpaidMoney)) < 0 ?
                                "earned_more_title".localized : "left_to_earned_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(abs(dailyMoneyGoal.floatValue() - (dayPaidMoney + dayUnpaidMoney)).formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: dailyMoneyGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("worked_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                            
                            Text(viewModel.selectedDay.currentDateString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !dailyHoursGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $dayHoursProgressValue)
                            .fixedSize(horizontal: false, vertical: false)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.dayHoursProgressValue * 100) + "%")
                                .animation(nil, value: dayHoursProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("hours_worked_colon_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(dayHours.formatFloatToString() + "h / \(dailyHoursGoal)h")
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: dailyHoursGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                Group {
                    NativeAdView(nativeViewModel: nativeDayDetailsViewModel, style: .card)
                        .frame(height: 300)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.whiteTheme, lineWidth: 3)
                        }
                        .padding(6)
                        .onAppear {
                            nativeDayDetailsViewModel.refreshAd()
                        }
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
            }
            .padding(.horizontal, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    withAnimation(.interpolatingSpring(duration: 0.4)) {
                        viewModel.selectToday()
                        proxy.scrollTo("top", anchor: .top)
                    }
                } label: {
                    Text("today_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blackWhite, in: .rect(cornerRadius: 18))
                        .padding(.bottom, 30)
                }
                .hide(if: viewModel.selectedDay.isToday())
            }
        }
    }

    var weekDetailsView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: viewModel.backwardToLastWeek) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        WeekCard(isSelected: true, week: viewModel.selectedWeek)
                        
                        Spacer()
                        
                        Button(action: viewModel.forwardToNextWeek) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                }
                .id("top")
                .frame(height: 62)
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, isWeekDetailsBannerAdLoaded || userSubscriptionViewModel.subscriptionActive ? 2 : -16)
                
                ZStack {
                    Button {
                        showSubscriptionPlanView.toggle()
                    } label: {
                        Text("buy_subscription_title".localized)
                            .font(.nunitoBold(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.blueRibbon)
                    }
                    .padding(.horizontal, 2)
                    
                    Group {
                        BannerAd(isLoaded: $isWeekDetailsBannerAdLoaded, unitID: weekDetailsBannerId)
                            .frame(height: 50)
                            .cornerRadius(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.whiteTheme, lineWidth: 3)
                            }
                            .padding(6)
                    }
                    .background(.whiteTheme)
                    .cornerRadius(12)
                    .opacity(isWeekDetailsBannerAdLoaded ? 1 : 0)
                }
                .padding(.bottom, isWeekDetailsBannerAdLoaded ? 2 : -16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
                
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("earned_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                            
                            Text(viewModel.selectedWeek.currentWeekString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                                        
                    VStack(spacing: 8) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("paid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text(weekPaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("unpaid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text(weekUnpaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("total_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text((weekPaidMoney + weekUnpaidMoney).formatFloatToString() +
                                " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !weeklyMoneyGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $weekMoneyProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.weekMoneyProgressValue * 100) + "%")
                                .animation(nil, value: weekMoneyProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text((weeklyMoneyGoal.floatValue() - (weekPaidMoney + weekUnpaidMoney)) < 0 ?
                                "earned_more_title".localized : "left_to_earned_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(abs(weeklyMoneyGoal.floatValue() - (weekPaidMoney + weekUnpaidMoney)).formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: weeklyMoneyGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("worked_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                            
                            Text(viewModel.selectedWeek.currentWeekString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !weeklyHoursGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $weekHoursProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.weekHoursProgressValue * 100) + "%")
                                .animation(nil, value: weekHoursProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("hours_worked_colon_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(weekHours.formatFloatToString() + "h / \(weeklyHoursGoal)h")
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: weeklyHoursGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                Group {
                    NativeAdView(nativeViewModel: nativeWeekDetailsViewModel, style: .card)
                        .frame(height: 300)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.whiteTheme, lineWidth: 3)
                        }
                        .padding(6)
                        .onAppear {
                            nativeWeekDetailsViewModel.refreshAd()
                        }
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
            }
            .padding(.horizontal, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    withAnimation(.interpolatingSpring(duration: 0.4)) {
                        viewModel.selectedWeek = .now
                        proxy.scrollTo("top", anchor: .top)
                    }
                } label: {
                    Text("today_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blackWhite, in: .rect(cornerRadius: 18))
                        .padding(.bottom, 30)
                }
                .hide(if: viewModel.selectedWeek.isThisWeek())
            }
        }
    }

    var monthDetailsView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: viewModel.backwardToLastMonth) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        MonthCard(isSelected: true, month: viewModel.selectedMonth)
                        
                        Spacer()
                        
                        Button(action: viewModel.forwardToNextMonth) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                }
                .id("top")
                .frame(height: 62)
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, isMonthDetailsBannerAdLoaded || userSubscriptionViewModel.subscriptionActive ? 2 : -16)
                
                ZStack {
                    Button {
                        showSubscriptionPlanView.toggle()
                    } label: {
                        Text("buy_subscription_title".localized)
                            .font(.nunitoBold(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.blueRibbon)
                    }
                    .padding(.horizontal, 2)
                    
                    Group {
                        BannerAd(isLoaded: $isMonthDetailsBannerAdLoaded, unitID: monthDetailsBannerId)
                            .frame(height: 50)
                            .cornerRadius(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.whiteTheme, lineWidth: 3)
                            }
                            .padding(6)
                    }
                    .background(.whiteTheme)
                    .cornerRadius(12)
                    .opacity(isMonthDetailsBannerAdLoaded ? 1 : 0)
                }
                .padding(.bottom, isMonthDetailsBannerAdLoaded ? 2 : -16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("earned_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                            
                            Text(viewModel.selectedMonth.currentMonthString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    VStack(spacing: 8) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("paid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text(monthPaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("unpaid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text(monthUnpaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("total_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                            Text((monthPaidMoney + monthUnpaidMoney).formatFloatToString() +
                                " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !monthlyMoneyGoal.isEmpty)
                   
                    Group {
                        ProgressBar(percent: $monthMoneyProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.monthMoneyProgressValue * 100) + "%")
                                .animation(nil, value: monthMoneyProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text((monthlyMoneyGoal.floatValue() - (monthPaidMoney + monthUnpaidMoney)) < 0 ?
                                "earned_more_title".localized : "left_to_earned_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(abs(monthlyMoneyGoal.floatValue() - (monthPaidMoney + monthUnpaidMoney)).formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: monthlyMoneyGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("worked_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                            
                            Text(viewModel.selectedMonth.currentMonthString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !monthlyHoursGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $monthHoursProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.monthHoursProgressValue * 100) + "%")
                                .animation(nil, value: monthHoursProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("hours_worked_colon_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(monthHours.formatFloatToString() + "h / \(monthlyHoursGoal)h")
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: monthlyHoursGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                Group {
                    NativeAdView(nativeViewModel: nativeMonthDetailsViewModel, style: .card)
                        .frame(height: 300)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.whiteTheme, lineWidth: 3)
                        }
                        .padding(6)
                        .onAppear {
                            nativeMonthDetailsViewModel.refreshAd()
                        }
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
            }
            .padding(.horizontal, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    withAnimation(.interpolatingSpring(duration: 0.4)) {
                        viewModel.selectedMonth = .now
                        proxy.scrollTo("top", anchor: .top)
                    }
                } label: {
                    Text("today_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blackWhite, in: .rect(cornerRadius: 18))
                        .padding(.bottom, 30)
                }
                .hide(if: viewModel.selectedMonth.isThisMonth())
            }
        }
    }

    var yearDetailsView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: viewModel.backwardToLastYear) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        YearCard(isSelected: true, year: viewModel.selectedYear)
                        
                        Spacer()
                        
                        Button(action: viewModel.forwardToNextYear) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                }
                .id("top")
                .frame(height: 62)
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, isYearDetailsBannerAdLoaded || userSubscriptionViewModel.subscriptionActive ? 2 : -16)
                
                ZStack {
                    Button {
                        showSubscriptionPlanView.toggle()
                    } label: {
                        Text("buy_subscription_title".localized)
                            .font(.nunitoBold(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.blueRibbon)
                    }
                    .padding(.horizontal, 2)
                    
                    Group {
                        BannerAd(isLoaded: $isYearDetailsBannerAdLoaded, unitID: yearDetailsBannerId)
                            .frame(height: 50)
                            .cornerRadius(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.whiteTheme, lineWidth: 3)
                            }
                            .padding(6)
                    }
                    .background(.whiteTheme)
                    .cornerRadius(12)
                    .opacity(isYearDetailsBannerAdLoaded ? 1 : 0)
                }
                .padding(.bottom, isYearDetailsBannerAdLoaded ? 2 : -16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("earned_title".localized)
                                .font(.latoBold(size: 18))
                            
                            Text(viewModel.selectedYear.currentYearString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    VStack(spacing: 8) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("paid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                            Spacer()
                            Text(yearPaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("unpaid_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                            Spacer()
                            Text(yearUnpaidMoney.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("total_title".localized)
                                .font(.nunitoSemiBold(size: 16))
                            Spacer()
                            Text((yearPaidMoney + yearUnpaidMoney).formatFloatToString() +
                                " " + currencyIdentifier.uppercased())
                                .font(.latoBold(size: 18))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !yearlyMoneyGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $yearMoneyProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.yearMoneyProgressValue * 100) + "%")
                                .animation(nil, value: yearMoneyProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text((yearlyMoneyGoal.floatValue() - (yearPaidMoney + yearUnpaidMoney)) < 0 ?
                                "earned_more_title".localized : "left_to_earned_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(abs(yearlyMoneyGoal.floatValue() - (yearPaidMoney + yearUnpaidMoney)).formatFloatToString() + " " + currencyIdentifier.uppercased())
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: yearlyMoneyGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("worked_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundColor(.blackWhite)
                            
                            Text(viewModel.selectedYear.currentYearString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 16)
                    
                    Text(viewModel.goalTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                    
                    Text("setup_goal_home_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom], 16)
                        .padding(.top, 2)
                        .hide(if: !yearlyHoursGoal.isEmpty)
                    
                    Group {
                        ProgressBar(percent: $yearHoursProgressValue)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("plan_done_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(String(format: "%0.f", self.yearHoursProgressValue * 100) + "%")
                                .animation(nil, value: yearHoursProgressValue)
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("hours_worked_colon_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.gray)
                            Text(yearHours.formatFloatToString() + "h / \(yearlyHoursGoal)h")
                                .font(.nunitoSemiBold(size: 16))
                                .foregroundColor(.blackWhite)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .hide(if: yearlyHoursGoal.isEmpty)
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 2)
                
                Group {
                    NativeAdView(nativeViewModel: nativeYearDetailsViewModel, style: .card)
                        .frame(height: 300)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.whiteTheme, lineWidth: 3)
                        }
                        .padding(6)
                        .onAppear {
                            nativeYearDetailsViewModel.refreshAd()
                        }
                }
                .background(.whiteTheme)
                .cornerRadius(12)
                .padding(.bottom, 16)
                .hide(if: userSubscriptionViewModel.subscriptionActive)
            }
            .padding(.horizontal, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    withAnimation(.interpolatingSpring(duration: 0.4)) {
                        viewModel.selectedYear = .now
                        proxy.scrollTo("top", anchor: .top)
                    }
                } label: {
                    Text("today_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blackWhite, in: .rect(cornerRadius: 18))
                        .padding(.bottom, 30)
                }
                .hide(if: viewModel.selectedYear.isThisYear())
            }
        }
    }

    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack(spacing: 4) {
                    Text(item.title)
                        .font(selectedFilter == item ? .latoBlack(size: 16) : .latoRegular(size: 16))
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(selectedFilter == item ? .blackWhite : .gray)
                        .onAppear {
                            filtersWidthDict[item] = item.title.widthOfString(usingFont: .latoBold(size: 16))
                        }

                    if selectedFilter == item {
                        Rectangle()
                            .frame(width: filtersWidthDict[selectedFilter], height: 2)
                            .foregroundColor(.blueRibbon)
                            .matchedGeometryEffect(id: "periodFilter", in: filterAnimation)
                    } else {
                        Rectangle()
                            .frame(width: filtersWidthDict[item], height: 2)
                            .foregroundColor(.clear)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.easeOut(duration: 0.2), value: selectedFilter)
                .onTapGesture {
                    self.selectedFilter = item
                }
            }
        }
    }
}

extension HomeView {
    private func addItem() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        let newItem = Work(context: viewContext)
        newItem.id = UUID()
        newItem.periodType = PeriodFilter.day.rawValue
        newItem.startDate = .now.addingTimeInterval(-viewModel.stopwatch.elapsedTime)
        newItem.endDate = .now
        newItem.isPaid = false
        newItem.isOvertime = isOvertime
        newItem.hoursWorked = newItem.startDate.timeDifferenceInHours(to: newItem.endDate)
        
        if let selectedJob = jobs.first(where: { $0.name == selectedWorkName }) {
            newItem.job = selectedJob
            newItem.hourlyRate = selectedJob.hourlyRate * overTimeMultiplier
            newItem.moneyEarned = selectedJob.hourlyRate *
                newItem.startDate.timeDifferenceInHours(to: newItem.endDate) *
                overTimeMultiplier
            
            saveContext()
            selectedWork = newItem
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension HomeView {
    private func showAddWorkTimeView(work: Work? = nil) {
        selectedWork = work
        showAddWorkTimeView = true
    }
}

extension HomeView {
    private func startLiveActivityTimer(elapsedTime: TimeInterval) {
        guard let selectedWorkName else {
            return
        }

        let attributes = WorkTimeStatusAttributes(workName: selectedWorkName)
        let contentState = WorkTimeStatusAttributes.ContentState(workTimeInterval: elapsedTime)
        let content = ActivityContent(state: contentState, staleDate: nil)

        activity = try? Activity<WorkTimeStatusAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil)
    }

    private func stopLiveActivityTimer() {
        Task {
            await activity?.end(activity?.content, dismissalPolicy: .immediate)
        }
    }

    private func updateProgressBar() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
        withAnimation(.easeIn(duration: 0.6)) {
            switch selectedFilter {
            case .day:
                dayMoneyProgressValue = CGFloat((dayPaidMoney + dayUnpaidMoney) / dailyMoneyGoal.floatValue())
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = 0.0
                
                dayHoursProgressValue = CGFloat(dayHours / dailyHoursGoal.floatValue())
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = 0.0
            case .week:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = CGFloat((weekPaidMoney + weekUnpaidMoney) / weeklyMoneyGoal.floatValue())
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = 0.0
                                                           
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = CGFloat(weekHours / weeklyHoursGoal.floatValue())
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = 0.0
            case .month:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = CGFloat((monthPaidMoney + monthUnpaidMoney) / monthlyMoneyGoal.floatValue())
                yearMoneyProgressValue = 0.0
                                                           
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = CGFloat(monthHours / monthlyHoursGoal.floatValue())
                yearHoursProgressValue = 0.0
            case .year:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = CGFloat((yearPaidMoney + yearUnpaidMoney) / yearlyMoneyGoal.floatValue())
               
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = CGFloat(yearHours / yearlyHoursGoal.floatValue())
            }
        }
    }
    
    private func updateProgressBarInstant() {
        withAnimation(.easeIn(duration: 0.6)) {
            switch selectedFilter {
            case .day:
                dayMoneyProgressValue = CGFloat((dayPaidMoney + dayUnpaidMoney) / dailyMoneyGoal.floatValue())
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = 0.0
                
                dayHoursProgressValue = CGFloat(dayHours / dailyHoursGoal.floatValue())
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = 0.0
            case .week:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = CGFloat((weekPaidMoney + weekUnpaidMoney) / weeklyMoneyGoal.floatValue())
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = 0.0
                                                           
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = CGFloat(weekHours / weeklyHoursGoal.floatValue())
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = 0.0
            case .month:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = CGFloat((monthPaidMoney + monthUnpaidMoney) / monthlyMoneyGoal.floatValue())
                yearMoneyProgressValue = 0.0
                                                           
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = CGFloat(monthHours / monthlyHoursGoal.floatValue())
                yearHoursProgressValue = 0.0
            case .year:
                dayMoneyProgressValue = 0.0
                weekMoneyProgressValue = 0.0
                monthMoneyProgressValue = 0.0
                yearMoneyProgressValue = CGFloat((yearPaidMoney + yearUnpaidMoney) / yearlyMoneyGoal.floatValue())
               
                dayHoursProgressValue = 0.0
                weekHoursProgressValue = 0.0
                monthHoursProgressValue = 0.0
                yearHoursProgressValue = CGFloat(yearHours / yearlyHoursGoal.floatValue())
            }
        }
    }
}

extension HomeView {
    private func showAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let topViewController = UIApplication.shared.getTopViewController() else {
                print("Unable to get top view controller.")
                return
            }
            
            adManager.showAd(from: topViewController)
        }
    }
}

#Preview {
    HomeView()
}
