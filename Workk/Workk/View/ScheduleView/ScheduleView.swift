//
//  ScheduleView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 20/10/2023.
//

import Resolver
import SwiftUI

struct ScheduleView: View {
    @Namespace var filterAnimation
    
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: ScheduleViewModel = Resolver.resolve()
    
    @State private var selectedFilter: PeriodFilter = .day
    @State private var filtersWidthDict: [PeriodFilter : CGFloat] = [:]
    @State private var dayDeleteMode = false
    @State private var weekDeleteMode = false
    @State private var monthDeleteMode = false
    @State private var yearDeleteMode = false
    @State private var selectedEntries: [WorkPeriod] = []
    
    @State private var showAddNewEntry = false
    @State private var showAddNewWorkView: Bool = false
    
    @State private var selectedWorkName: String? = "All"
    
    private static var now = Date() // Cache now
    private let calendar: Calendar
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    var body: some View {
        VStack(spacing: 0) {
            periodFilterBar
                .padding(.top, 4)
                .padding(.horizontal, 8)
            
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
            .animation(.easeOut(duration: 0.2), value: selectedFilter)
        }
        .fullScreenCover(isPresented: $showAddNewEntry) {
            SubscriptionPlanView()
        }
    }
    
    var dayScheduleView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                CalendarView(
                    calendar: calendar,
                    date: $viewModel.selectedDay,
                    content: { date in
                        Button {
                            withAnimation(.interpolatingSpring(duration: 0.4)) {
                                viewModel.selectedDay = date
                            }
                        } label: {
                            Text("00")
                                .padding(8)
                                .foregroundColor(.clear)
                                .overlay {
                                    Capsule().fill(calendar.isDate(date, inSameDayAs: viewModel.selectedDay) ?
                                        .black : (calendar.isDateInToday(date) ? .wildSand : .clear))
                                    .padding(.horizontal, 4)
                                }
                                .accessibilityHidden(true)
                                .overlay {
                                    Text(date.currentDayNumberString)
                                        .font(calendar.isDate(date, inSameDayAs: viewModel.selectedDay) ?
                                            .latoBlack(size: 14) : (calendar.isDateInToday(date) ? .latoBlack(size: 14) : .latoRegular(size: 14)))
                                        .foregroundColor(calendar.isDate(date, inSameDayAs: viewModel.selectedDay) ? .white : .black)
                                }
                                .overlay {
                                    if let work = workSampleData.first(where: { $0.date.isSameDay(date: date) }) {
                                        Circle()
                                            .fill(work.date.isSameDay(date: viewModel.selectedDay) ? .white : .black)
                                            .frame(width: 5, height: 5)
                                            .padding(.top, 26)
                                    }
                                }
                        }
                    },
                    trailing: { date in
                        Text(date.currentDayNumberString)
                            .font(.latoRegular(size: 14))
                            .foregroundColor(.secondary)
                    },
                    header: { date in
                        Text(date.currentDayShortString)
                            .font(.latoRegular(size: 14))
                    },
                    title: { date in
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
                                Text(date.currentYearString)
                                    .font(.latoBold(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(date.currentMonthString)
                                    .font(.latoBlack(size: 26))
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
                        .padding(.bottom, 6)
                    }
                )
                .equatable()
                .padding(12)
                .background(.white)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                
                let selectedDayWork = workSampleData
                    .filter { $0.date.isSameDay(date: viewModel.selectedDay) }
                    .reduce(into: []) { $0.append($1.workPeriod) }
                    .flatMap { $0 }
                
                ZStack {
                    HStack(spacing: 0) {
                        DropDownPicker(selection: $selectedWorkName,
                                       addNewOption: $showAddNewWorkView,
                                       hint: "Select",
                                       options: ["All", "DAZN", "Revolut", "Long long name"],
                                       backgroundColor: .white)
                        
                        Spacer()
                        
                        Button {
                            if dayDeleteMode {
                                selectedEntries = []
                            }
                            
                            withAnimation(.bouncy(duration: 0.4)) {
                                dayDeleteMode.toggle()
                            }
                        } label: {
                            Text(dayDeleteMode ? "Cancel" : "Delete")
                                .font(.latoRegular(size: 12))
                        }
                        .opacity(selectedDayWork.isEmpty ? 0 : 1)
                    }
                }
                .zIndex(1000)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)
                .padding(.horizontal, 24)
                
                if !selectedDayWork.isEmpty {
                    ForEach(selectedDayWork) { workPeriod in
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(workPeriod.title)
                                    .font(.latoBold(size: 18))
                                    .padding(.bottom, 4)
                                
                                Text("21:23 - 23:50")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("200 PLN")
                                    .font(.latoBold(size: 16))
                                    .padding(.bottom, 4)
                                
                                Text("8h" + " | " + "25 PLN/h")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            
                            Button {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if let index = selectedEntries.firstIndex(where: { $0.id == workPeriod.id }) {
                                        selectedEntries.remove(at: index)
                                    } else {
                                        selectedEntries.append(workPeriod)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedEntries.contains(where: { $0.id == workPeriod.id }) ? "checkmark.square" : "square")
                            }
                            .padding(.trailing, 16)
                            .hide(if: !dayDeleteMode)
                        }
                        .background(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                    }
                } else {
                    Text("No Entries Found")
                        .font(.latoRegular(size: 18))
                        .padding()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    if dayDeleteMode {
                        // TODO: Add remove logic
                    } else {
                        showAddNewEntry = true
                    }
                } label: {
                    Text(dayDeleteMode ? "Delete" : "Add new entry")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black)
                        .cornerRadius(18)
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
                .padding(.vertical, 12)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            let selectedWeekWork = workSampleData
                .filter { $0.date.isSameWeek(date: viewModel.selectedWeek) }
                .reduce(into: []) { $0.append($1.workPeriod) }
                .flatMap { $0 }
            
            ZStack {
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddNewWorkView,
                                   hint: "Select",
                                   options: ["All", "DAZN", "Revolut", "Long long name"],
                                   backgroundColor: .white)
                    
                    Spacer()
                    
                    Button {
                        if weekDeleteMode {
                            selectedEntries = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            weekDeleteMode.toggle()
                        }
                    } label: {
                        Text(weekDeleteMode ? "Cancel" : "Delete")
                            .font(.latoRegular(size: 12))
                    }
                    .opacity(selectedWeekWork.isEmpty ? 0 : 1)
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 4)
            .padding(.horizontal, 24)
            
            Spacer()
            
            if !selectedWeekWork.isEmpty {
                ScrollView {
                    ForEach(selectedWeekWork) { workPeriod in
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(workPeriod.title)
                                    .font(.latoBold(size: 18))
                                    .padding(.bottom, 4)
                                
                                Text("21:23 - 23:50")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("200 PLN")
                                    .font(.latoBold(size: 16))
                                    .padding(.bottom, 4)
                                
                                Text("8h" + " | " + "25 PLN/h")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            
                            Button {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if let index = selectedEntries.firstIndex(where: { $0.id == workPeriod.id }) {
                                        selectedEntries.remove(at: index)
                                    } else {
                                        selectedEntries.append(workPeriod)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedEntries.contains(where: { $0.id == workPeriod.id }) ? "checkmark.square" : "square")
                            }
                            .padding(.trailing, 16)
                            .hide(if: !weekDeleteMode)
                        }
                        .background(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                }
            } else {
                Text("No Entries Found")
                    .font(.latoRegular(size: 18))
                    .padding()
            }
            
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    if weekDeleteMode {
                        // TODO: Add remove logic
                    } else {
                        showAddNewEntry = true
                    }
                } label: {
                    Text(weekDeleteMode ? "Delete" : "Add new entry")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black)
                        .cornerRadius(18)
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
                .padding(.vertical, 12)
                
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            let selectedMonthWork = workSampleData
                .filter { $0.date.isSameMonth(date: viewModel.selectedMonth) }
                .reduce(into: []) { $0.append($1.workPeriod) }
                .flatMap { $0 }
            
            ZStack {
                HStack(spacing: 0) {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddNewWorkView,
                                   hint: "Select",
                                   options: ["All", "DAZN"],
                                   backgroundColor: .white)
                    
                    Spacer()
                    
                    Button {
                        if monthDeleteMode {
                            selectedEntries = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            monthDeleteMode.toggle()
                        }
                    } label: {
                        Text(monthDeleteMode ? "Cancel" : "Delete")
                            .font(.latoRegular(size: 12))
                    }
                    .opacity(selectedMonthWork.isEmpty ? 0 : 1)
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)
            
//            Spacer()
            
            if !selectedMonthWork.isEmpty {
                ScrollView {
                    ForEach(selectedMonthWork) { workPeriod in
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(workPeriod.title)
                                    .font(.latoBold(size: 18))
                                    .padding(.bottom, 4)
                                
                                Text("21:23 - 23:50")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("200 PLN")
                                    .font(.latoBold(size: 16))
                                    .padding(.bottom, 4)
                                
                                Text("8h" + " | " + "25 PLN/h")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            
                            Button {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if let index = selectedEntries.firstIndex(where: { $0.id == workPeriod.id }) {
                                        selectedEntries.remove(at: index)
                                    } else {
                                        selectedEntries.append(workPeriod)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedEntries.contains(where: { $0.id == workPeriod.id }) ? "checkmark.square" : "square")
                            }
                            .padding(.trailing, 16)
                            .hide(if: !monthDeleteMode)
                        }
                        .background(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                }
            } else {
                Text("No Entries Found")
                    .font(.latoRegular(size: 18))
                    .padding()
            }
            
//            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    if monthDeleteMode {
                        // TODO: Add remove logic
                    } else {
                        showAddNewEntry = true
                    }
                } label: {
                    Text(monthDeleteMode ? "Delete" : "Add new entry")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black)
                        .cornerRadius(18)
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
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            let selectedYearWork = workSampleData
                .filter { $0.date.isSameYear(date: viewModel.selectedYear) }
                .reduce(into: []) { $0.append($1.workPeriod) }
                .flatMap { $0 }
            
            ZStack {
                HStack {
                    DropDownPicker(selection: $selectedWorkName,
                                   addNewOption: $showAddNewWorkView,
                                   hint: "Select",
                                   options: ["All", "DAZN"],
                                   backgroundColor: .white)
                    
                    Spacer()
                    
                    Button {
                        if yearDeleteMode {
                            selectedEntries = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            yearDeleteMode.toggle()
                        }
                    } label: {
                        Text(yearDeleteMode ? "Cancel" : "Delete")
                            .font(.latoRegular(size: 12))
                    }
                    .opacity(selectedYearWork.isEmpty ? 0 : 1)
                }
            }
            .zIndex(1000)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)
            
            if !selectedYearWork.isEmpty {
                ScrollView {
                    ForEach(selectedYearWork) { workPeriod in
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(workPeriod.title)
                                    .font(.latoBold(size: 18))
                                    .padding(.bottom, 4)
                                
                                Text("21:23 - 23:50")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("200 PLN")
                                    .font(.latoBold(size: 16))
                                    .padding(.bottom, 4)
                                
                                Text("8h" + " | " + "25 PLN/h")
                                    .font(.latoRegular(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            
                            Button {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if let index = selectedEntries.firstIndex(where: { $0.id == workPeriod.id }) {
                                        selectedEntries.remove(at: index)
                                    } else {
                                        selectedEntries.append(workPeriod)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedEntries.contains(where: { $0.id == workPeriod.id }) ? "checkmark.square" : "square")
                            }
                            .padding(.trailing, 16)
                            .hide(if: !yearDeleteMode)
                        }
                        .background(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                }
            } else {
                Text("No Entries Found")
                    .font(.latoRegular(size: 18))
                    .padding()
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    if yearDeleteMode {
                        // TODO: Add remove logic
                    } else {
                        showAddNewEntry = true
                    }
                } label: {
                    Text(yearDeleteMode ? "Delete" : "Add new entry")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.black)
                        .cornerRadius(18)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                Spacer()
                
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
                .padding()
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
