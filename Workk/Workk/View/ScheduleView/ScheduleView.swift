//
//  ScheduleView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 20/10/2023.
//

import Resolver
import SwiftUI

struct ScheduleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @Namespace var filterAnimation
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: ScheduleViewModel = Resolver.resolve()
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
        
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)],
        predicate: NSPredicate(format: "periodType == %@", "day")
    ) private var dayWorks: FetchedResults<Work>
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)],
        predicate: NSPredicate(format: "periodType IN %@", ["week"])
    ) private var weekWorks: FetchedResults<Work>
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)],
        predicate: NSPredicate(format: "periodType IN %@", ["month"])
    ) private var monthWorks: FetchedResults<Work>
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)],
        predicate: NSPredicate(format: "periodType IN %@", ["year"])
    ) private var yearWorks: FetchedResults<Work>
    
    @State private var selectedJob: Job? = nil
    @State private var selectedWork: Work? = nil
    @State private var screenSize: CGSize = .zero
    @State private var selectedWorks = Set<Work>()
    @State private var selectedFilter: PeriodFilter = .day
    @State private var filtersWidthDict: [PeriodFilter: CGFloat] = [:]
    @State private var deleteMode = false
    @State private var selectedEntries: [WorkPeriod] = []
    @State private var selectedWorkName: String? = "All"
    @State private var showAddWorkTime = false
    @State private var showAddJobView: Bool = false
    @State private var showSubscriptionPlanView = false
    @State private var showDeletionView = false
    
    @State private var isDayDetailsBannerAdLoaded: Bool = false
    @State private var isWeekDetailsBannerAdLoaded: Bool = false
    @State private var isMonthDetailsBannerAdLoaded: Bool = false
    @State private var isYearDetailsBannerAdLoaded: Bool = false
    
    private let calendar: Calendar
    
    private let dayScheduleBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let weekScheduleBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let monthScheduleBannerId = "REDACTED_SERVICE_CONFIGURATION"
    private let yearScheduleBannerId = "REDACTED_SERVICE_CONFIGURATION"
    
    @State private var periodFilterSize: CGSize = .zero
    private let calendarTitleViewHeight: CGFloat = 56.0
    private let weekLabelHeight: CGFloat = 28.0
    private let horizontalPadding: CGFloat = 16.0
    private let topPadding: CGFloat = 24.0
    private let bottomPadding: CGFloat = 24.0
    
    private var calendarRowHeight: CGFloat {
        screenSize.height < 700 ? 38 : 44
    }
    
    private var calendarHeight: CGFloat {
        let selectedMonthDates = makeDays()
        if CGFloat(selectedMonthDates.count / 7).rounded() > 5.0 {
            return screenSize.height < 700 ? 356.0 : 398.0
        }
        
        return screenSize.height < 700 ? 320.0 : 354.0
    }
    
    private var monthProgress: CGFloat {
        let selectedMonthDates = makeDays()
        if let index = selectedMonthDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: viewModel.selectedDay) }) {
            return CGFloat(index / 7).rounded()
        }
        
        return 1.0
    }
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    var body: some View {
        VStack(spacing: 0) {
            periodFilterBar
                .padding(.top, 4)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .size { periodFilterSize = $0 }
                .background(.wildSand)
            
            TabView(selection: $selectedFilter) {
                dayScheduleView
                    .tag(PeriodFilter.day)
                
                weekScheduleView
                    .tag(PeriodFilter.week)
                
                monthScheduleView
                    .tag(PeriodFilter.month)
                
                yearScheduleView
                    .tag(PeriodFilter.year)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.4), value: selectedFilter)
            .background(.wildSand)
        }
        .background(ViewSizeReader(size: $screenSize))
        .fullScreenCover(isPresented: $showAddWorkTime) {
            AddWorkTimeView(
                addWorkTimePlace: .schedule,
                selectedWork: $selectedWork,
                selectedFilter: $selectedFilter,
                selectedWorkName: $selectedWorkName
            )
        }
        .fullScreenCover(isPresented: $showAddJobView) {
            AddJobView(selectedJob: $selectedJob)
        }
        .fullScreenCover(isPresented: $showSubscriptionPlanView) {
            SubscriptionPlanView()
        }
        .sheet(isPresented: $showDeletionView) {
            WorksDeletionView(selectedWorks: $selectedWorks)
                .background(.wildSand)
        }
    }
    
    var dayScheduleView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack {
                    Calendar()
                        .padding(.bottom, 64)
                    
                    if dayWorks
                        .filter({ selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true })
                        .filter({ $0.startDate.isSameDay(date: viewModel.selectedDay) })
                        .isEmpty
                    {
                        VStack {
                            ZStack {
                                Button {
                                    showSubscriptionPlanView.toggle()
                                } label: {
                                    Text("Buy subscription to remove ads")
                                        .font(.nunitoBold(size: 18))
                                        .foregroundColor(.blueRibbon)
                                }
                                
                                Group {
                                    BannerAd(isLoaded: $isDayDetailsBannerAdLoaded, unitID: dayScheduleBannerId)
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
                                .padding(.horizontal, 16)
                                .opacity(isDayDetailsBannerAdLoaded ? 1 : 0)
                            }
                            .padding(.bottom, 16)
                            
                            Text("No Entries Found")
                                .font(.latoRegular(size: 18))
                        }
                        .padding(.top, calendarHeight + 62)
                    }
                }
                .zIndex(1002)
                                
                ForEach(dayWorks
                    .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
                    .filter { $0.startDate.isSameDay(date: viewModel.selectedDay) })
                { work in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(work.jobName)
                                .font(.latoBold(size: 18))
                                
                            Text(work.startDate.currentHourString + " - " + work.endDate.currentHourString)
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.black)
                        }
                        .padding(16)
                            
                        Spacer()
                            
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(work.moneyEarned.formatFloatToString())" + " PLN")
                                .font(.latoBold(size: 16))
                                
                            Text(work.hoursWorkedTimeDifference + " | " + "\(work.hourlyRate.formatFloatToString())" + " PLN/h")
                                .font(.latoRegular(size: 12))
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                            
                            Text(work.isPaid ? "Paid" : "Unpaid")
                                .font(.latoBold(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                            
                        Image(systemName: selectedWorks.contains(where: { $0.id == work.id }) ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding([.trailing, .vertical], 16)
                            .hide(if: !deleteMode)
                    }
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .transition(.opacity)
                    .onTapGesture {
                        if deleteMode {
                            withAnimation(.bouncy(duration: 0.4)) {
                                if selectedWorks.contains(where: { $0.id == work.id }) {
                                    selectedWorks.remove(work)
                                } else {
                                    selectedWorks.insert(work)
                                }
                            }
                        } else {
                            showAddWorkTimeView(work: work)
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    if deleteMode {
                        deleteSelectedWorks()
                        deleteMode = false
                    } else {
                        showAddWorkTimeView()
                    }
                } label: {
                    Text(deleteMode ? "Delete" : "Add work time")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.black, in: .rect(cornerRadius: 18))
                
                Button {
                    if selectedWorks.count > 0 {
                        showDeletionView = true
                    }
                } label: {
                    Text("\(selectedWorks.count)")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black, in: .rect(cornerRadius: 18))
                        .hide(if: !deleteMode)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    var weekScheduleView: some View {
        VStack(spacing: 0) {
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
                .padding(.vertical, 12)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            ZStack {
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddJobView,
                                   hint: "Select",
                                   options: ["All"] + jobs.compactMap { $0.name },
                                   backgroundColor: .white,
                                   maxWidth: 200)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                            viewModel.selectedWeek = .now
                        }
                    } label: {
                        Text("Today")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.black, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 8)
                    .hide(if: viewModel.selectedWeek.isThisWeek())
                    
                    Button {
                        if deleteMode {
                            selectedWorks = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            deleteMode.toggle()
                        }
                    } label: {
                        Text(deleteMode ? "Cancel" : "Delete")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.white, in: .rect(cornerRadius: 18))
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
            
            if !weekWorks
                .filter({ selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true })
                .filter({ $0.startDate.isSameWeek(date: viewModel.selectedWeek) })
                .isEmpty
            {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(weekWorks
                            .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
                            .filter { $0.startDate.isSameWeek(date: viewModel.selectedWeek) })
                        { work in
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(work.jobName)
                                        .font(.latoBold(size: 18))
                                    
                                    Text(work.startDate.currentWeekScheduleString)
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.black)
                                }
                                .padding(16)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(work.moneyEarned.formatFloatToString())" + " PLN")
                                        .font(.latoBold(size: 16))
                                    
                                    Text(work.hoursWorkedString + " | " + "\(work.hourlyRate.formatFloatToString())" + " PLN/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                    
                                    Text(work.isPaid ? "Paid" : "Unpaid")
                                        .font(.latoBold(size: 14))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                
                                Image(systemName: selectedWorks.contains(where: { $0.id == work.id }) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding([.trailing, .vertical], 16)
                                    .hide(if: !deleteMode)
                            }
                            .background(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                            .onTapGesture {
                                if deleteMode {
                                    withAnimation(.bouncy(duration: 0.4)) {
                                        if selectedWorks.contains(where: { $0.id == work.id }) {
                                            selectedWorks.remove(work)
                                        } else {
                                            selectedWorks.insert(work)
                                        }
                                    }
                                } else {
                                    showAddWorkTimeView(work: work)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ZStack {
                        Button {
                            showSubscriptionPlanView.toggle()
                        } label: {
                            Text("Buy subscription to remove ads")
                                .font(.nunitoBold(size: 18))
                                .foregroundColor(.blueRibbon)
                        }
                        
                        Group {
                            BannerAd(isLoaded: $isWeekDetailsBannerAdLoaded, unitID: weekScheduleBannerId)
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
                        .padding(.horizontal, 16)
                        .opacity(isWeekDetailsBannerAdLoaded ? 1 : 0)
                    }
                    .padding(.bottom, 16)
                    
                    Text("No Entries Found")
                        .font(.latoRegular(size: 18))
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    if deleteMode {
                        deleteSelectedWorks()
                        deleteMode = false
                    } else {
                        showAddWorkTimeView()
                    }
                } label: {
                    Text(deleteMode ? "Delete" : "Add work time")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.black, in: .rect(cornerRadius: 18))
                
                Button {
                    if selectedWorks.count > 0 {
                        showDeletionView = true
                    }
                } label: {
                    Text("\(selectedWorks.count)")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black, in: .rect(cornerRadius: 18))
                        .hide(if: !deleteMode)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    var monthScheduleView: some View {
        VStack(spacing: 0) {
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
                .padding(.vertical, 12)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            ZStack {
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddJobView,
                                   hint: "Select",
                                   options: ["All"] + jobs.compactMap { $0.name },
                                   backgroundColor: .white,
                                   maxWidth: 200)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                            viewModel.selectedMonth = .now
                        }
                    } label: {
                        Text("Today")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.black, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 8)
                    .hide(if: viewModel.selectedMonth.isThisMonth())
                    
                    Button {
                        if deleteMode {
                            selectedWorks = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            deleteMode.toggle()
                        }
                    } label: {
                        Text(deleteMode ? "Cancel" : "Delete")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.white, in: .rect(cornerRadius: 18))
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
            
            if !monthWorks
                .filter({ selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true })
                .filter({ $0.startDate.isSameMonth(date: viewModel.selectedMonth) })
                .isEmpty
            {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(monthWorks
                            .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
                            .filter { $0.startDate.isSameMonth(date: viewModel.selectedMonth) })
                        { work in
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(work.jobName)
                                        .font(.latoBold(size: 18))
                                    
                                    Text(work.startDate.currentMonthString)
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.black)
                                }
                                .padding(16)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " PLN")
                                        .font(.latoBold(size: 16))
                                    
                                    Text(work.hoursWorkedString + " | " + work.hourlyRate.formatFloatToString() + " PLN/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                    
                                    Text(work.isPaid ? "Paid" : "Unpaid")
                                        .font(.latoBold(size: 14))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                
                                Image(systemName: selectedWorks.contains(where: { $0.id == work.id }) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                                    .hide(if: !deleteMode)
                            }
                            .background(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                            .onTapGesture {
                                if deleteMode {
                                    withAnimation(.bouncy(duration: 0.4)) {
                                        if selectedWorks.contains(where: { $0.id == work.id }) {
                                            selectedWorks.remove(work)
                                        } else {
                                            selectedWorks.insert(work)
                                        }
                                    }
                                } else {
                                    showAddWorkTimeView(work: work)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack {
                    ZStack {
                        Button {
                            showSubscriptionPlanView.toggle()
                        } label: {
                            Text("Buy subscription to remove ads")
                                .font(.nunitoBold(size: 18))
                                .foregroundColor(.blueRibbon)
                        }
                        
                        Group {
                            BannerAd(isLoaded: $isMonthDetailsBannerAdLoaded, unitID: monthScheduleBannerId)
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
                        .padding(.horizontal, 16)
                        .opacity(isMonthDetailsBannerAdLoaded ? 1 : 0)
                    }
                    .padding(.bottom, 16)
                    
                    Text("No Entries Found")
                        .font(.latoRegular(size: 18))
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    if deleteMode {
                        deleteSelectedWorks()
                        deleteMode = false
                    } else {
                        showAddWorkTimeView()
                    }
                } label: {
                    Text(deleteMode ? "Delete" : "Add work time")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.black, in: .rect(cornerRadius: 18))
                
                Button {
                    if selectedWorks.count > 0 {
                        showDeletionView = true
                    }
                } label: {
                    Text("\(selectedWorks.count)")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black, in: .rect(cornerRadius: 18))
                        .hide(if: !deleteMode)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    var yearScheduleView: some View {
        VStack(spacing: 0) {
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
                .padding(.vertical, 20)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            ZStack {
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddJobView,
                                   hint: "Select",
                                   options: ["All"] + jobs.compactMap { $0.name },
                                   backgroundColor: .white,
                                   maxWidth: 200)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                            viewModel.selectedYear = .now
                        }
                    } label: {
                        Text("Today")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.black, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 8)
                    .hide(if: viewModel.selectedYear.isThisYear())
                    
                    Button {
                        if deleteMode {
                            selectedWorks = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            deleteMode.toggle()
                        }
                    } label: {
                        Text(deleteMode ? "Cancel" : "Delete")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.white, in: .rect(cornerRadius: 18))
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
            
            if !yearWorks
                .filter({ selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true })
                .filter({ $0.startDate.isSameYear(date: viewModel.selectedYear) })
                .isEmpty
            {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(yearWorks
                            .filter { selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true }
                            .filter { $0.startDate.isSameYear(date: viewModel.selectedYear) })
                        { work in
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(work.jobName)
                                        .font(.latoBold(size: 18))
                                    
                                    Text(work.startDate.currentYearString)
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.black)
                                }
                                .padding(16)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " PLN")
                                        .font(.latoBold(size: 16))
                                    
                                    Text(work.hoursWorkedString + " | " + work.hourlyRate.formatFloatToString() + " PLN/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                    
                                    Text(work.isPaid ? "Paid" : "Unpaid")
                                        .font(.latoBold(size: 14))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                
                                Image(systemName: selectedWorks.contains(where: { $0.id == work.id }) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                                    .hide(if: !deleteMode)
                            }
                            .background(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                            .onTapGesture {
                                if deleteMode {
                                    withAnimation(.bouncy(duration: 0.4)) {
                                        if selectedWorks.contains(where: { $0.id == work.id }) {
                                            selectedWorks.remove(work)
                                        } else {
                                            selectedWorks.insert(work)
                                        }
                                    }
                                } else {
                                    showAddWorkTimeView(work: work)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack {
                    ZStack {
                        Button {
                            showSubscriptionPlanView.toggle()
                        } label: {
                            Text("Buy subscription to remove ads")
                                .font(.nunitoBold(size: 18))
                                .foregroundColor(.blueRibbon)
                        }
                        
                        Group {
                            BannerAd(isLoaded: $isYearDetailsBannerAdLoaded, unitID: yearScheduleBannerId)
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
                        .padding(.horizontal, 16)
                        .opacity(isYearDetailsBannerAdLoaded ? 1 : 0)
                    }
                    .padding(.bottom, 16)
                    
                    Text("No Entries Found")
                        .font(.latoRegular(size: 18))
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    if deleteMode {
                        deleteSelectedWorks()
                        deleteMode = false
                    } else {
                        showAddWorkTimeView()
                    }
                } label: {
                    Text(deleteMode ? "Delete" : "Add work time")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.black, in: .rect(cornerRadius: 18))
                
                Button {
                    if selectedWorks.count > 0 {
                        showDeletionView = true
                    }
                } label: {
                    Text("\(selectedWorks.count)")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black, in: .rect(cornerRadius: 18))
                        .hide(if: !deleteMode)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack(spacing: 4) {
                    Text(item.title)
                        .font(selectedFilter == item ? .latoBlack(size: 18) : .latoRegular(size: 18))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
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
                .frame(maxWidth: .infinity)
                .animation(.easeOut(duration: 0.2), value: selectedFilter)
                .onTapGesture {
                    self.selectedFilter = item
                }
            }
        }
    }
    
    @ViewBuilder
    func Calendar() -> some View {
        let month = viewModel.selectedDay.startOfMonth(using: calendar)
        let days = makeDays()
        
        GeometryReader { geometry in
            let size = geometry.size
            let minY = geometry.frame(in: .global).minY - safeAreaInsets.top - periodFilterSize.height
            /// Converting Scroll into Progress
            let maxHeight = size.height - (calendarTitleViewHeight + weekLabelHeight + calendarRowHeight + topPadding + bottomPadding - 4)
            @State var progress = max(min((-minY / maxHeight), 1), 0)
            
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(.wildSand)
                        .ignoresSafeArea()
                        .frame(height: size.height - (maxHeight * progress), alignment: .top)
                        .clipped()
                        .contentShape(.rect)
                        .offset(y: -minY)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: viewModel.daysInWeek)) {
                        Section {
                            ForEach(days, id: \.self) { date in
                                if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                    Button {
                                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                                            viewModel.selectedDay = date
                                        }
                                    } label: {
                                        Text("00")
                                            .minimumScaleFactor(0.5)
                                            .padding(screenSize.height < 700 ? 5 : 8)
                                            .foregroundColor(.clear)
                                            .overlay {
                                                Capsule().fill(date.isSameDay(date: viewModel.selectedDay) ?
                                                    .black : (date.isToday() ? Color.primary.opacity(0.08) : .clear))
                                                    .padding(.horizontal, 4)
                                            }
                                            .accessibilityHidden(true)
                                            .overlay {
                                                Text(date.currentDayNumberString)
                                                    .minimumScaleFactor(0.5)
                                                    .font(date.isSameDay(date: viewModel.selectedDay) ?
                                                        .latoBlack(size: 14) : (date.isToday() ? .latoBlack(size: 14) : .latoRegular(size: 14)))
                                                    .foregroundColor(date.isSameDay(date: viewModel.selectedDay) ? .white : .black)
                                            }
                                            .overlay {
                                                if !dayWorks
                                                    .filter({ selectedWorkName != "All" ? $0.job?.name == selectedWorkName : true })
                                                    .filter({ $0.startDate.isSameDay(date: date) })
                                                    .isEmpty
                                                {
                                                    Circle()
                                                        .fill(date.isSameDay(date: viewModel.selectedDay) ? .white : .black)
                                                        .frame(width: screenSize.height < 700 ? 4 : 5,
                                                               height: screenSize.height < 700 ? 4 : 5)
                                                        .padding(.top, screenSize.height < 700 ? 22 : 26)
                                                }
                                            }
                                    }
                                } else {
                                    Button {
                                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                                            viewModel.selectedDay = date
                                        }
                                    } label: {
                                        Text(date.currentDayNumberString)
                                            .font(.latoRegular(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .offset(y: -(monthProgress * calendarRowHeight + 2) * progress)
                        } header: {
                            ZStack {
                                Rectangle()
                                    .fill(.white)
                                    .ignoresSafeArea()
                                VStack {
                                    HStack {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                guard let newDate = calendar.date(
                                                    byAdding: .month,
                                                    value: -1,
                                                    to: viewModel.selectedDay
                                                ) else {
                                                    return
                                                }
                                                
                                                viewModel.selectedDay = newDate
                                            }
                                        } label: {
                                            Label(
                                                title: { Text("Previous") },
                                                icon: { Image(systemName: "chevron.left") }
                                            )
                                            .labelStyle(IconOnlyLabelStyle())
                                            .padding(.horizontal)
                                            .frame(maxHeight: .infinity)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 0) {
                                            Text(month.currentYearString)
                                                .font(.latoBold(size: 14))
                                                .foregroundColor(.gray)
                                                .minimumScaleFactor(0.5)
                                            
                                            Text(month.currentMonthString)
                                                .font(.latoBlack(size: 26))
                                                .minimumScaleFactor(0.5)
                                        }
                                        .padding()
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                guard let newDate = calendar.date(
                                                    byAdding: .month,
                                                    value: 1,
                                                    to: viewModel.selectedDay
                                                ) else {
                                                    return
                                                }
                                                
                                                viewModel.selectedDay = newDate
                                            }
                                        } label: {
                                            Label(
                                                title: { Text("Next") },
                                                icon: { Image(systemName: "chevron.right") }
                                            )
                                            .labelStyle(IconOnlyLabelStyle())
                                            .padding(.horizontal)
                                            .frame(maxHeight: .infinity)
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(days.prefix(viewModel.daysInWeek), id: \.self) { date in
                                            Text(date.currentDayShortString)
                                                .minimumScaleFactor(0.01)
                                                .fixedSize(horizontal: true, vertical: false)
                                                .font(.nunitoSemiBold(size: 14))
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 6)
                            .background(.white)
                            .zIndex(1001)
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.horizontal, 12)
                    .background(.white)
                    .cornerRadius(12)
                    .frame(height: size.height - (maxHeight * progress), alignment: .top)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .clipped()
                    .contentShape(.rect)
                    .offset(y: -minY)
                }
                                
                Rectangle()
                    .fill(.wildSand)
                    .ignoresSafeArea()
                    .frame(height: 12)
                    .clipped()
                    .contentShape(.rect)
                    .offset(y: -minY)
                
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddJobView,
                                   hint: "Select",
                                   options: ["All"] + jobs.compactMap { $0.name },
                                   backgroundColor: .white,
                                   maxWidth: 200)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.interpolatingSpring(duration: 0.4)) {
                            viewModel.selectedDay = .now
                        }
                    } label: {
                        Text("Today")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.black, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 8)
                    .opacity(viewModel.selectedDay.isToday() ? 0 : 1)
                    
                    Button {
                        if deleteMode {
                            selectedWorks = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            deleteMode.toggle()
                        }
                    } label: {
                        Text(deleteMode ? "Cancel" : "Delete")
                            .font(.latoBold(size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.white, in: .rect(cornerRadius: 18))
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(.wildSand)
                .offset(y: -minY)
                .padding(.horizontal, 16)
                .zIndex(1001)
                
                Rectangle()
                    .fill(.wildSand)
                    .ignoresSafeArea()
                    .frame(height: 12)
                    .clipped()
                    .contentShape(.rect)
                    .offset(y: -minY)
            }
        }
        .frame(height: calendarHeight)
        .zIndex(1000)
    }
}

extension ScheduleView {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: viewModel.selectedDay),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

extension ScheduleView {
    private func showAddWorkTimeView(work: Work? = nil) {
        selectedWork = work
        showAddWorkTime = true
    }
}

extension ScheduleView {
    private func addItem() {
        withAnimation {
            let newItem = Job(context: viewContext)
            newItem.id = UUID()
            newItem.hourlyRate = 32.0
            newItem.name = "DAZN"
            
            saveContext()
        }
    }
    
    private func deleteSelectedWorks() {
        withAnimation {
            for item in selectedWorks {
                viewContext.delete(item)
            }
            selectedWorks.removeAll()
            saveContext()
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
