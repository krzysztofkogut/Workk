//
//  HomeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import ActivityKit
import Resolver
import SwiftUI

struct HomeView: View {
    @Namespace var filterAnimation
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: HomeViewModel = Resolver.resolve()
    
    @State private var selectedFilter: PeriodFilter = .day
    @State private var selectedFilterWidth: CGFloat = 0
    @State private var activity: Activity<WorkTimeStatusAttributes>? = nil
    @State private var progressValue: CGFloat = 0
    @State private var timeReciver = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    @State private var showSubscriptionPlan = false
    @State private var countWorkTime = false
    @State private var pauseTimer = false
    @State private var toggleDynamicIsland: Bool = false
    @State private var selectedWorkName: String? = nil
    
    @State private var filtersWidthDict: [PeriodFilter : CGFloat] = [:]
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
            VStack(spacing: 0) {
                HStack {
                    DropDownPicker(selection: $selectedWorkName, hint: "Select", options: ["DAZN"])
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
                
                self.progressValue = 0.9
            })
            .onReceive(timeReciver) { _ in
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                }
            }
            .withHomeRoutes()
            .fullScreenCover(isPresented: $showSubscriptionPlan) {
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
                    RollingText(font: .latoBold(size: 56), value: $viewModel.stopwatch.hours)
                    Text(":")
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBold(size: 56), value: $viewModel.stopwatch.minutes)
                    RollingText(font: .latoLight(size: 16), value: $viewModel.stopwatch.seconds)
                        .padding(.leading, 2)
                }
                .transition(.opacity)
                .padding(.leading, 24)
                .opacity(countWorkTime ? 1 : 0)
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    RollingText(font: .latoBold(size: 56), value: $viewModel.currentTime.hour)
                    Text(":")
                        .font(.latoBold(size: 56))
                    RollingText(font: .latoBold(size: 56), value: $viewModel.currentTime.min)
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
                    withAnimation(.easeInOut(duration: 0.6)) {
                        countWorkTime.toggle()
                    }
                    
                    viewModel.stopwatch.isRunning = true
                    startLiveActivityTimer(elapsedTime: viewModel.stopwatch.elapsedTime)
                }
            } label: {
                Text(countWorkTime ? (pauseTimer ? "Start" : "Stop") : "Start timer")
                    .frame(width: countWorkTime ? 80 : 120, height: 44)
            }
            .modifier(FilledButton())
            .background(.black)
            .cornerRadius(6)
            
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
                    
                    withAnimation(.easeInOut(duration: 0.6)) {
                        countWorkTime = false
                        pauseTimer = false
                    }
                } label : {
                    Text("Save")
                        .frame(width: 80, height: 44)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.cranberry, lineWidth: 4)
                }
                .modifier(BorderedRoundedButton())
                .cornerRadius(6)
            }
            
            Button {
                if countWorkTime {
                    stopLiveActivityTimer()
                    
                    withAnimation(.easeInOut(duration: 0.6)) {
                        countWorkTime = false
                        pauseTimer = false
                    }
                } else {
                    showSubscriptionPlan.toggle()
                }
                
                viewModel.stopwatch.reset()
            } label: {
                Text(countWorkTime ? "Reset" : "Save time")
                    .frame(width: countWorkTime ? 80 : 120, height: 44)
            }
            .modifier(BorderedRoundedButton())
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.persianBlue, lineWidth: 4)
            }
            .cornerRadius(6)
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
            VStack {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastDaysWeek) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, -8)
                    
                    DayPicker(selection: $viewModel.selectedDayInWeek, days: viewModel.daysOfCurrentWeek)
                        .padding(.vertical, 8)
                    
                    Button(action: viewModel.forwardToNextDaysWeek) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, -8)
                    .padding(.trailing, 16)
                }
            }
            .background { Capsule().fill(.white) }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            Group {
                BannerAd(unitID: "REDACTED_SERVICE_CONFIGURATION")
                    .frame(minHeight: 50, maxHeight: 80)
                    .padding(8)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            VStack {
                HStack {
                    Text(PeriodFilter.day.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $progressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.progressValue * 100) + "%")
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
            .padding(.horizontal, 24)
            
            Spacer(minLength: 60)
        }
    }
    
    var weekDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastWeek) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    WeekCard(isSelected: true, week: viewModel.selectedWeek)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 20)
            }
            .background { Capsule().fill(.white) }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            VStack {
                HStack {
                    Text(PeriodFilter.week.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $progressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.progressValue * 100) + "%")
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            Spacer(minLength: 60)
        }
    }
    
    var monthDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastMonth) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    MonthCard(isSelected: true, month: viewModel.selectedMonth)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 20)
                    
            }
            .background { Capsule().fill(.white) }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            VStack {
                HStack {
                    Text(PeriodFilter.month.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $progressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.progressValue * 100) + "%")
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            Spacer(minLength: 60)
        }
    }
    
    var yearDetailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack(spacing: 0) {
                    Button(action: viewModel.backwardToLastYear) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    YearCard(isSelected: true, year: viewModel.selectedYear)
                    
                    Spacer()
                    
                    Button(action: viewModel.forwardToNextYear) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 20)
            }
            .background { Capsule().fill(.white) }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            VStack {
                HStack {
                    Text(PeriodFilter.year.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(12)
                
                ProgressBar(percent: $progressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.progressValue * 100) + "%")
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
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            Spacer(minLength: 60)
        }
    }
    
    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack(spacing: 4) {
                    Text(item.title)
                        .font(selectedFilter == item ? .latoBold(size: 16) : .latoRegular(size: 16))
                        .foregroundColor(selectedFilter == item ? .black : .gray)
                        .onAppear {
                            filtersWidthDict[item] = item.title.widthOfString(usingFont: .latoBold(size: 16))
                        }
                    
                    if selectedFilter == item {
                        Rectangle()
                            .frame(width: filtersWidthDict[selectedFilter], height: 2)
                            .cornerRadius(3)
                            .foregroundColor(.persianBlue)
                            .matchedGeometryEffect(id: "periodFilter", in: filterAnimation)
                    } else {
                        Rectangle()
                            .frame(width: filtersWidthDict[item], height: 2)
                            .cornerRadius(3)
                            .foregroundColor(.clear)
                    }
                }
                .padding()
                .animation(.easeOut(duration: 0.2), value: selectedFilter)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.selectedFilter = item
                    }
                }
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
}

#Preview {
    HomeView()
}
