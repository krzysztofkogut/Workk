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
    @Namespace var filterAnimation
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: HomeViewModel = Resolver.resolve()
    
    @StateObject private var nativeDayDetailsViewModel: NativeAdViewModel = NativeAdViewModel(
                                                        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
                                                        requestInterval: 300)
    
    @StateObject private var nativeWeekDetailsViewModel: NativeAdViewModel = NativeAdViewModel(
                                                        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
                                                        requestInterval: 300)
    
    @StateObject private var nativeMonthDetailsViewModel: NativeAdViewModel = NativeAdViewModel(
                                                        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
                                                        requestInterval: 300)
    
    @StateObject private var nativeYearDetailsViewModel: NativeAdViewModel = NativeAdViewModel(
                                                        adUnitID: "REDACTED_SERVICE_CONFIGURATION",
                                                        requestInterval: 300)
    
    @State private var selectedWork: Work? = nil
    @State private var selectedFilter: PeriodFilter = .day
    @State private var selectedFilterWidth: CGFloat = 0
    @State private var activity: Activity<WorkTimeStatusAttributes>? = nil
    @State private var dayProgressValue: CGFloat = 0
    @State private var weekProgressValue: CGFloat = 0
    @State private var monthProgressValue: CGFloat = 0
    @State private var yearProgressValue: CGFloat = 0
    @State private var timeReciver = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    @State private var countWorkTime = false
    @State private var pauseTimer = false
    @State private var toggleDynamicIsland: Bool = true
    @State private var selectedWorkName: String? = nil
    @State private var showAddJobView: Bool = false
    @State private var showAddWorkTimeView: Bool = false
    @State private var showSubscriptionPlanView = false
    @State private var filtersWidthDict: [PeriodFilter : CGFloat] = [:]
    
    @State private var isDayDetailsBannerAdLoaded: Bool = false
    @State private var isWeekDetailsBannerAdLoaded: Bool = false
    @State private var isMonthDetailsBannerAdLoaded: Bool = false
    @State private var isYearDetailsBannerAdLoaded: Bool = false
    
    private let dayDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let weekDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let monthDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let yearDetailsBannerId = "REDACTED_SERVICE_CONFIGURATION"
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
            VStack(spacing: 0) {
                HStack {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddJobView,
                                   hint: "Select",
                                   options: ["DAZN"], 
                                   backgroundColor: .wildSand)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .zIndex(1000)
                
                headerActionsView
                    .padding(.top, 16)
                
                Spacer()
                
                detailsView
                    .ignoresSafeArea()
            }
            .onAppear(perform: {
                withAnimation(.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                }
                
                Task {
                    await updateProgressBar()
                }
            })
            .onReceive(timeReciver) { _ in
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                }
            }
            .onChange(of: selectedFilter) { _ in
                Task {
                    await updateProgressBar()
                }
            }
            .withHomeRoutes()
            .fullScreenCover(isPresented: $showAddJobView) {
                AddJobView()
            }
            .fullScreenCover(isPresented: $showAddWorkTimeView) {
                AddWorkTimeView(selectedWork: $selectedWork,
                    selectedFilter: $selectedFilter,
                    selectedWorkName: $selectedWorkName)
            }
            .sheet(isPresented: $showSubscriptionPlanView) {
                SubscriptionPlanView()
            }
        }
    }
}

extension HomeView {
    var headerActionsView: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .center) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.stopwatch.hours)
                    Text(":")
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.stopwatch.minutes)
                    RollingText(font: .latoLight(size: 16), value: $viewModel.stopwatch.seconds)
                        .padding(.leading, 2)
                }
                .transition(.opacity)
                .padding(.leading, 24)
                .opacity(countWorkTime ? 1 : 0)
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.currentTime.hour)
                    Text(":")
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBlack(size: 56), value: $viewModel.currentTime.min)
                    RollingText(font: .latoLight(size: 16), value: $viewModel.currentTime.sec)
                        .padding(.leading, 2)
                }
                .transition(.opacity)
                .padding(.leading, 24)
                .opacity(countWorkTime ? 0 : 1)
            }
            
            Text(viewModel.currentDateString)
                .font(.latoRegular(size: 16))
                .padding(.bottom, 16)
            
            addWorkTimeButtons
        }
        .background(.white)
        .padding(.bottom, 16)
    }
    
    var addWorkTimeButtons: some View {
        HStack {
            Button {
                if countWorkTime {
                    pauseTimer.toggle()
                    viewModel.stopwatch.isRunning.toggle()
                    pauseTimer ? stopLiveActivityTimer() : startLiveActivityTimer(elapsedTime: viewModel.stopwatch.elapsedTime)
                } else {
                    withAnimation(.bouncy(duration: 0.6)) {
                        countWorkTime.toggle()
                    }
                    
                    viewModel.stopwatch.isRunning = true
                    startLiveActivityTimer(elapsedTime: viewModel.stopwatch.elapsedTime)
                }
            } label: {
                Text(countWorkTime ? (pauseTimer ? "Start" : "Stop") : "Start timer")
                    .font(.latoBold(size: 16))
                    .frame(width: countWorkTime ? 90 : 120, height: 44)
            }
            .modifier(FilledButton())
            .background(.black)
            .cornerRadius(24)
            
            if countWorkTime {
                Button {
                    UIApplication.shared.inAppNotification(adaptForDynamicIsland: toggleDynamicIsland, timeout: 4, swipeToClose: true) { isDynamicIslandEnabled in
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2, content: {
                                    Text("Saved your work time")
                                        .font(.latoBold(size: 18))
                                        .foregroundStyle(.white)
                                    
                                    Text(viewModel.currentDateString)
                                        .font(.latoRegular(size: 14))
                                        .foregroundStyle(.gray)
                                })
                                .padding(.top, isDynamicIslandEnabled ? 20 : 0)
                                
                                Spacer(minLength: 0)
                                
                                Text(viewModel.stopwatch.elapsedTime.timeString)
                                    .font(.latoBold(size: 22))
                                    .foregroundStyle(.gray)
                                    .padding(.top, isDynamicIslandEnabled ? 20 : 0)
                            }
                            .padding(.horizontal, 36)
                            .padding(.vertical, 16)
                            
                            Rectangle()
                                .frame(width: 40, height: 4)
                                .cornerRadius(2)
                                .foregroundColor(.athensGray)
                                .padding(.bottom, 8)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)
                        }
                    }
                    
                    viewModel.stopwatch.reset()
                    stopLiveActivityTimer()
                    
                    withAnimation(.bouncy(duration: 0.6)) {
                        countWorkTime = false
                        pauseTimer = false
                    }
                } label : {
                    Text("Save")
                        .font(.latoBold(size: 16))
                        .frame(width: 90, height: 44)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.black, lineWidth: 4)
                }
                .modifier(BorderedRoundedButton())
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
            } label: {
                Text(countWorkTime ? "Reset" : "Save time")
                    .font(.latoBold(size: 16))
                    .frame(width: countWorkTime ? 90 : 120, height: 44)
            }
            .modifier(BorderedRoundedButton())
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.blueRibbon, lineWidth: 4)
            }
            .cornerRadius(24)
        }
    }
    
    var periodCircleFilterBar: some View {
        HStack(spacing: 16) {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack {
                    Text(item.title)
                        .font(FontManager.smallBodyBold)
                        .foregroundColor(viewModel.selectedFilter == item ? .white : .black)
                        .padding(.horizontal, 12)
                        .background (
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(viewModel.selectedFilter == item ? .cranberry : .white)
                                .frame(height: 24)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.selectedFilter == item ? .clear : .black, lineWidth: 1)
                                .frame(height: 24)
                        }
                }
                .onTapGesture {
                    withAnimation(.easeOut) {
                        self.viewModel.selectedFilter = item
                    }
                }
            }
        }
        .padding(.top, 24)
    }
    
    var detailsView: some View {
        VStack(spacing: 0) {
            periodFilterBar
                .padding(.top, 4)
                .padding(.horizontal, 8)
                .padding()
            
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
        .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
    }
    
    var dayDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastDaysWeek) {
                        Image(systemName: "chevron.left")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, -8)
                    
                    DayPicker(selection: $viewModel.selectedDayInWeek, days: viewModel.daysOfCurrentWeek)
                    
                    Button(action: viewModel.forwardToNextDaysWeek) {
                        Image(systemName: "chevron.right")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, -8)
                    .padding(.trailing, 12)
                }
            }
            .frame(height: 62)
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, isDayDetailsBannerAdLoaded ? 2 : -16)
            
            ZStack {
                Button {
                    showSubscriptionPlanView.toggle()
                } label: {
                    Text("Buy subscription to remove ads")
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.blueRibbon)
                }
                
                Group {
                    BannerAd(isLoaded: $isDayDetailsBannerAdLoaded, unitID: dayDetailsBannerId)
                        .frame(height: 50)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white, lineWidth: 3)
                        }
                        .padding(6)
                }
                .background(.white)
                .cornerRadius(12)
//                .padding(.horizontal, 24)
                .opacity(isDayDetailsBannerAdLoaded ? 1 : 0)
            }
            .padding(.bottom, isDayDetailsBannerAdLoaded ? 2 : -16)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(PeriodFilter.day.statsTitle + " you earned")
                            .font(.latoBold(size: 16))
                        
                        Text(viewModel.selectedDayInWeek.currentDayString)
                            .font(.latoRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("120 PLN")
                            .font(.latoBold(size: 18))
                    }
                    
                    HStack {
                        Text("Unpaid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("250 PLN")
                            .font(.latoBold(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            VStack {
                HStack {
                    Text(PeriodFilter.day.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $dayProgressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.dayProgressValue * 100) + "%")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 2)
                
                HStack(spacing: 6) {
                    Text("Left to be done:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text("4h")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            Group {
                NativeAdView(nativeViewModel: nativeDayDetailsViewModel, style: .card)
                    .frame(height: 300)
                    .cornerRadius(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white, lineWidth: 3)
                    }
                    .padding(6)
                    .onAppear {
                        nativeDayDetailsViewModel.refreshAd()
                    }
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 16)
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 24)
    }
    
    var weekDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastWeek) {
                        Image(systemName: "chevron.left")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    WeekCard(isSelected: true, week: viewModel.selectedWeek)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextWeek) {
                        Image(systemName: "chevron.right")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 62)
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, isWeekDetailsBannerAdLoaded ? 2 : -16)
            
            ZStack {
                Button {
                    showSubscriptionPlanView.toggle()
                } label: {
                    Text("Buy subscription to remove ads")
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.blueRibbon)
                }
                
                Group {
                    BannerAd(isLoaded: $isWeekDetailsBannerAdLoaded, unitID: weekDetailsBannerId)
                        .frame(height: 50)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white, lineWidth: 3)
                        }
                        .padding(6)
                }
                .background(.white)
                .cornerRadius(12)
//                .padding(.horizontal, 24)
                .opacity(isWeekDetailsBannerAdLoaded ? 1 : 0)
            }
            .padding(.bottom, isWeekDetailsBannerAdLoaded ? 2 : -16)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(PeriodFilter.week.statsTitle + " you earned")
                            .font(.latoBold(size: 16))
                        
                        Text(viewModel.selectedWeek.currentWeekString)
                            .font(.latoRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("120 PLN")
                            .font(.latoBold(size: 18))
                    }
                    
                    HStack {
                        Text("Unpaid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("250 PLN")
                            .font(.latoBold(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            VStack {
                HStack {
                    Text(PeriodFilter.week.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $weekProgressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.weekProgressValue * 100) + "%")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 2)
                
                HStack(spacing: 6) {
                    Text("Left to be done:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text("4h")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            Group {
                NativeAdView(nativeViewModel: nativeWeekDetailsViewModel, style: .card)
                    .frame(height: 300)
                    .cornerRadius(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white, lineWidth: 3)
                    }
                    .padding(6)
                    .onAppear {
                        nativeWeekDetailsViewModel.refreshAd()
                    }
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 16)
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 24)
    }
    
    var monthDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastMonth) {
                        Image(systemName: "chevron.left")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    MonthCard(isSelected: true, month: viewModel.selectedMonth)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextMonth) {
                        Image(systemName: "chevron.right")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
                    
            }
            .frame(height: 62)
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, isMonthDetailsBannerAdLoaded ? 2 : -16)
            
            ZStack {
                Button {
                    showSubscriptionPlanView.toggle()
                } label: {
                    Text("Buy subscription to remove ads")
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.blueRibbon)
                }
                
                Group {
                    BannerAd(isLoaded: $isMonthDetailsBannerAdLoaded, unitID: monthDetailsBannerId)
                        .frame(height: 50)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white, lineWidth: 3)
                        }
                        .padding(6)
                }
                .background(.white)
                .cornerRadius(12)
//                .padding(.horizontal, 24)
                .opacity(isMonthDetailsBannerAdLoaded ? 1 : 0)
            }
            .padding(.bottom, isMonthDetailsBannerAdLoaded ? 2 : -16)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(PeriodFilter.month.statsTitle + " you earned")
                            .font(.latoBold(size: 16))
                        
                        Text(viewModel.selectedMonth.currentMonthString)
                            .font(.latoRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("120 PLN")
                            .font(.latoBold(size: 18))
                    }
                    
                    HStack {
                        Text("Unpaid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("250 PLN")
                            .font(.latoBold(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            VStack {
                HStack {
                    Text(PeriodFilter.month.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $monthProgressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.monthProgressValue * 100) + "%")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 2)
                
                HStack(spacing: 6) {
                    Text("Left to be done:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text("4h")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            Group {
                NativeAdView(nativeViewModel: nativeMonthDetailsViewModel, style: .card)
                    .frame(height: 300)
                    .cornerRadius(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white, lineWidth: 3)
                    }
                    .padding(6)
                    .onAppear {
                        nativeMonthDetailsViewModel.refreshAd()
                    }
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 16)
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 24)
    }
    
    var yearDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastYear) {
                        Image(systemName: "chevron.left")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    YearCard(isSelected: true, year: viewModel.selectedYear)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextYear) {
                        Image(systemName: "chevron.right")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 62)
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, isYearDetailsBannerAdLoaded ? 2 : -16)
            
            ZStack {
                Button {
                    showSubscriptionPlanView.toggle()
                } label: {
                    Text("Buy subscription to remove ads")
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.blueRibbon)
                }
                
                Group {
                    BannerAd(isLoaded: $isYearDetailsBannerAdLoaded, unitID: yearDetailsBannerId)
                        .frame(height: 50)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white, lineWidth: 3)
                        }
                        .padding(6)
                }
                .background(.white)
                .cornerRadius(12)
//                .padding(.horizontal, 24)
                .opacity(isYearDetailsBannerAdLoaded ? 1 : 0)
            }
            .padding(.bottom, isYearDetailsBannerAdLoaded ? 2 : -16)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(PeriodFilter.year.statsTitle + " you earned")
                            .font(.latoBold(size: 16))
                        
                        Text(viewModel.selectedYear.currentYearString)
                            .font(.latoRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("120 PLN")
                            .font(.latoBold(size: 18))
                    }
                    
                    HStack {
                        Text("Unpaid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("250 PLN")
                            .font(.latoBold(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            VStack {
                HStack {
                    Text(PeriodFilter.year.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $yearProgressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.yearProgressValue * 100) + "%")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 2)
                
                HStack(spacing: 6) {
                    Text("Left to be done:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text("4h")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 2)
            
            Group {
                NativeAdView(nativeViewModel: nativeYearDetailsViewModel, style: .card)
                    .frame(height: 300)
                    .cornerRadius(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white, lineWidth: 3)
                    }
                    .padding(6)
                    .onAppear {
                        nativeYearDetailsViewModel.refreshAd()
                    }
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 16)
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 24)
    }
    
    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                Spacer()
                
                VStack(spacing: 4) {
                    Text(item.title)
                        .font(selectedFilter == item ? .latoBlack(size: 16) : .latoRegular(size: 16))
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(selectedFilter == item ? .black : .gray)
                        .onAppear {
                            filtersWidthDict[item] = item.title.widthOfString(usingFont: .latoBold(size: 18))
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
                .animation(.easeOut(duration: 0.2), value: selectedFilter)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.selectedFilter = item
                    }
                }
                
                Spacer()
            }
        }
    }
}

extension HomeView {
    private func startLiveActivityTimer(elapsedTime: TimeInterval) {
        guard let selectedWorkName else {
            return
        }
        
        let attributes = WorkTimeStatusAttributes(workName: selectedWorkName)
        let state = WorkTimeStatusAttributes.ContentState(workTimeInterval: elapsedTime)
        
        activity = try? Activity<WorkTimeStatusAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
    }
    
    private func stopLiveActivityTimer() {
        Task {
            await activity?.end(using: activity?.contentState, dismissalPolicy: .immediate)
        }
    }
    
    private func updateProgressBar() async {
        try? await Task.sleep(nanoseconds: 200_000_000)
        withAnimation(.easeIn(duration: 0.6)) {
            switch selectedFilter {
            case .day:
                dayProgressValue = 0.9
                weekProgressValue = 0.0
                monthProgressValue = 0.0
                yearProgressValue = 0.0
            case .week:
                dayProgressValue = 0.0
                weekProgressValue = 0.4
                monthProgressValue = 0.0
                yearProgressValue = 0.0
            case .month:
                dayProgressValue = 0.0
                weekProgressValue = 0.0
                monthProgressValue = 0.6
                yearProgressValue = 0.0
            case .year:
                dayProgressValue = 0.0
                weekProgressValue = 0.0
                monthProgressValue = 0.0
                yearProgressValue = 0.5
            }
        }
    }
}

#Preview {
    HomeView()
}
