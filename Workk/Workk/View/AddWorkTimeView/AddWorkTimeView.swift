//
//  AddWorkTimeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/09/2024.
//

import Resolver
import SwiftUI

struct AddWorkTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Namespace var filterAnimation
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
    
    @ObservedObject private var viewModel: ScheduleViewModel = Resolver.resolve()
    
    @Binding var selectedWork: Work?
    @Binding var selectedFilter: PeriodFilter
    @Binding var selectedWorkName: String?
    
    @State private var showAddJobView: Bool = false
    @State private var filtersWidthDict: [PeriodFilter: CGFloat] = [:]
    
    @State private var dayStartDate: Date = .now
    @State private var dayEndDate: Date = .now
    @State private var isPaidDay = false
    @State private var isHourlyRateDay = false
    @State private var hourlyRateDay: String = ""
    @State private var moneyEarnedDay: String = ""
    @State private var projectDay: String = ""
    @State private var taskDay: String = ""
    @State private var noteDay: String = ""
    @State private var isDaySaveButtonEnabled = false
    
    @State private var weekDate: Date? = .now
    @State private var isPaidWeek = false
    @State private var moneyEarnedWeek: String = ""
    @State private var projectWeek: String = ""
    @State private var taskWeek: String = ""
    @State private var noteWeek: String = ""
    @State private var isWeekSaveButtonEnabled = false
    
    @State private var monthDate: Date = .now
    @State private var isPaidMonth = false
    @State private var moneyEarnedMonth: String = ""
    @State private var projectMonth: String = ""
    @State private var taskMonth: String = ""
    @State private var noteMonth: String = ""
    @State private var isMonthSaveButtonEnabled = false
    
    @State private var yearDate: Date = .now
    @State private var isPaidYear = false
    @State private var moneyEarnedYear: String = ""
    @State private var projectYear: String = ""
    @State private var taskYear: String = ""
    @State private var noteYear: String = ""
    @State private var isYearSaveButtonEnabled = false
            
    var body: some View {
        VStack {
            HStack {
                DropDownPicker(selection: $selectedWorkName,
                               addNewOption: $showAddJobView,
                               hint: "Select",
                               options: jobs.compactMap { $0.name },
                               backgroundColor: .wildSand)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                        .font(.title)
                }
            }
            .zIndex(1000)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Text(selectedWork == nil ? "Add new work time" : "Update work time")
                .font(.latoBold(size: 28))
                .foregroundColor(.black)
                .padding(.bottom, 32)
            
            periodFilterBar
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
                .hide(if: selectedWork != nil)
                        
            TabView(selection: $selectedFilter) {
                addDayWorkTimeView
                    .tag(PeriodFilter.day)
                
                addWeekWorkTimeView
                    .tag(PeriodFilter.week)
                
                addMonthWorkTimeView
                    .tag(PeriodFilter.month)
                
                addYearWorkTimeView
                    .tag(PeriodFilter.year)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.2), value: selectedFilter)
            .onAppear {
                self.dayStartDate = .now.updatingMonthAndDay(from: viewModel.selectedDay) ?? .now
                self.dayEndDate = .now.updatingMonthAndDay(from: viewModel.selectedDay) ?? .now
                if hourlyRateDay.isEmpty {
                    hourlyRateDay = formatFloatToString(from: jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate)
                }
                setupView()
            }
            .onChange(of: dayStartDate) { newValue in
                if newValue > dayEndDate {
                    dayEndDate = newValue
                }
                
                updateSaveButtonState()
            }
            .onChange(of: dayEndDate) { newValue in
                if newValue < dayStartDate {
                    DispatchQueue.main.async {
                        dayEndDate = dayStartDate
                    }
                }
                
                updateSaveButtonState()
            }
            .onChange(of: hourlyRateDay) { newValue in
                hourlyRateDay = formatNumberInput(newValue)
                updateSaveButtonState()
            }
            .onChange(of: moneyEarnedDay) { newValue in
                moneyEarnedDay = formatNumberInput(newValue)
                updateSaveButtonState()
            }
            .onChange(of: moneyEarnedWeek) { newValue in
                moneyEarnedWeek = formatNumberInput(newValue)
                updateSaveButtonState()
            }
            .onChange(of: moneyEarnedMonth) { newValue in
                moneyEarnedMonth = formatNumberInput(newValue)
                updateSaveButtonState()
            }
            .onChange(of: moneyEarnedYear) { newValue in
                moneyEarnedYear = formatNumberInput(newValue)
                updateSaveButtonState()
            }
            .onChange(of: selectedFilter) { _ in UIApplication.shared.dismissKeyboard() }
            .onChange(of: selectedWorkName) { _ in updateSaveButtonState() }
            .onChange(of: isPaidDay) { _ in updateSaveButtonState() }
            .onChange(of: isHourlyRateDay) { _ in updateSaveButtonState() }
            .onChange(of: projectDay) { _ in updateSaveButtonState() }
            .onChange(of: taskDay) { _ in updateSaveButtonState() }
            .onChange(of: noteDay) { _ in updateSaveButtonState() }
            .onChange(of: weekDate) { _ in updateSaveButtonState() }
            .onChange(of: isPaidWeek) { _ in updateSaveButtonState() }
            .onChange(of: projectWeek) { _ in updateSaveButtonState() }
            .onChange(of: taskWeek) { _ in updateSaveButtonState() }
            .onChange(of: noteWeek) { _ in updateSaveButtonState() }
            .onChange(of: monthDate) { _ in updateSaveButtonState() }
            .onChange(of: isPaidMonth) { _ in updateSaveButtonState() }
            .onChange(of: projectMonth) { _ in updateSaveButtonState() }
            .onChange(of: taskMonth) { _ in updateSaveButtonState() }
            .onChange(of: noteMonth) { _ in updateSaveButtonState() }
            .onChange(of: yearDate) { _ in updateSaveButtonState() }
            .onChange(of: isPaidYear) { _ in updateSaveButtonState() }
            .onChange(of: projectYear) { _ in updateSaveButtonState() }
            .onChange(of: taskYear) { _ in updateSaveButtonState() }
            .onChange(of: noteYear) { _ in updateSaveButtonState() }
        }
        .fullScreenCover(isPresented: $showAddJobView) {
            AddJobView()
        }
    }
    
    var addDayWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("Start Date")
                        .font(.latoRegular(size: 16))
                    
                    DateTextField(date: $dayStartDate, components: [.date, .hourAndMinute]) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yyyy, HH:mm"
                        return formatter.string(from: date)
                    }
                    .multilineTextAlignment(.trailing)
                    .font(.latoBold(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                .padding(.horizontal, 24)
                
                HStack(spacing: 0) {
                    Text("End Date")
                        .font(.latoRegular(size: 16))
                    
                    DateTextField(date: $dayEndDate, components: [.date, .hourAndMinute]) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yyyy, HH:mm"
                        return formatter.string(from: date)
                    }
                    .multilineTextAlignment(.trailing)
                    .font(.latoBold(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                .padding(.horizontal, 24)
                
                HStack(spacing: 0) {
                    Text("Is paid")
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidDay)
                }
                .padding(.horizontal, 16)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                .padding(.horizontal, 24)
                
                HStack(spacing: 0) {
                    Text("Hourly rate")
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isHourlyRateDay)
                }
                .padding(.horizontal, 16)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                .padding(.horizontal, 24)
                
                TextField(isHourlyRateDay ? "Hourly rate" : "Money earned", text: isHourlyRateDay ? $hourlyRateDay : $moneyEarnedDay)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
                
                TextField("Project", text: $projectDay)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
                
                TextField("Task", text: $taskDay)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
                
                MultilineTextField(placeHolder: "Note", text: $noteDay)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.white)
            }
            .disabled(!isDaySaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isDaySaveButtonEnabled ? .black : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
    
    var addWeekWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
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
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("Is paid")
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidWeek)
                }
                .padding(.horizontal, 16)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Money earned", text: $moneyEarnedWeek)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Project", text: $projectWeek)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Task", text: $taskWeek)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "Note", text: $noteWeek)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.white)
            }
            .disabled(!(!moneyEarnedWeek.isEmpty && selectedWorkName != "All"))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                withAnimation {
                    if !moneyEarnedWeek.isEmpty, selectedWorkName != "All" {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.black)
                    } else {
                        RoundedRectangle(cornerRadius: 18.0)
                            .fill(.gray)
                    }
                }
            )
            .padding(.bottom, 16)
        }
    }
    
    var addMonthWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
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
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("Is paid")
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidMonth)
                }
                .padding(.horizontal, 16)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Money earned", text: $moneyEarnedMonth)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Project", text: $projectMonth)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Task", text: $taskMonth)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "Note", text: $noteMonth)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.white)
            }
            .disabled(!isMonthSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isMonthSaveButtonEnabled ? .black : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
    
    var addYearWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
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
                    .padding(.vertical, 18)
                }
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("Is paid")
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidYear)
                }
                .padding(.horizontal, 16)
                .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Money earned", text: $moneyEarnedYear)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Project", text: $projectYear)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                TextField("Task", text: $taskYear)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "Note", text: $noteYear)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.wildSand, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.white)
            }
            .disabled(!isYearSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isYearSaveButtonEnabled ? .black : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
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
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.selectedFilter = item
                    }
                }
            }
        }
    }
}

extension AddWorkTimeView {
    private func addItem() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        
        let newItem = Work(context: viewContext)
        newItem.id = UUID()
        newItem.periodType = selectedFilter.rawValue
        newItem.job = jobs.first(where: { $0.name == selectedWorkName })
        
        switch selectedFilter {
        case .day:
            newItem.startDate = dayStartDate
            newItem.endDate = dayEndDate
            newItem.isPaid = isPaidDay
            newItem.project = projectDay
            newItem.task = taskDay
            newItem.note = noteDay
            if isHourlyRateDay, let rate = formatter.number(from: hourlyRateDay) {
                newItem.hourlyRate = rate.floatValue
                newItem.moneyEarned = rate.floatValue * dayStartDate.timeDifferenceInHours(to: dayEndDate)
            } else if !isHourlyRateDay, let moneyEarned = formatter.number(from: moneyEarnedDay) {
                newItem.hourlyRate = moneyEarned.floatValue / dayStartDate.timeDifferenceInHours(to: dayEndDate)
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        case .week:
            newItem.startDate = viewModel.selectedWeek.startOfWeek()
            newItem.endDate = viewModel.selectedWeek.endOfWeek()
            newItem.isPaid = isPaidWeek
            newItem.project = projectWeek
            newItem.task = taskWeek
            newItem.note = noteWeek
            if let moneyEarned = formatter.number(from: moneyEarnedWeek) {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        case .month:
            newItem.startDate = viewModel.selectedMonth.startOfMonth()
            newItem.endDate = viewModel.selectedMonth.endOfMonth()
            newItem.isPaid = isPaidMonth
            newItem.project = projectMonth
            newItem.task = taskMonth
            newItem.note = noteMonth
            if let moneyEarned = formatter.number(from: moneyEarnedMonth) {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        case .year:
            newItem.startDate = viewModel.selectedYear.startOfYear()
            newItem.endDate = viewModel.selectedYear.endOfYear()
            newItem.isPaid = isPaidYear
            newItem.project = projectYear
            newItem.task = taskYear
            newItem.note = noteYear
            if let moneyEarned = formatter.number(from: moneyEarnedYear) {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        }
        
        saveContext()
    }
    
    private func updateItem() {
        guard let work = selectedWork, let periodType = work.periodType else {
            return
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        
        work.job = jobs.first(where: { $0.name == selectedWorkName })
        
        switch periodType {
        case PeriodFilter.day.rawValue:
            work.startDate = dayStartDate
            work.endDate = dayEndDate
            work.isPaid = isPaidDay
            work.project = projectDay
            work.task = taskDay
            work.note = noteDay
            if isHourlyRateDay, let rate = formatter.number(from: hourlyRateDay) {
                work.hourlyRate = rate.floatValue
                work.moneyEarned = rate.floatValue * dayStartDate.timeDifferenceInHours(to: dayEndDate)
            } else if !isHourlyRateDay, let moneyEarned = formatter.number(from: moneyEarnedDay) {
                work.hourlyRate = moneyEarned.floatValue / dayStartDate.timeDifferenceInHours(to: dayEndDate)
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        case PeriodFilter.week.rawValue:
            work.startDate = viewModel.selectedWeek.startOfWeek()
            work.endDate = viewModel.selectedWeek.endOfWeek()
            work.isPaid = isPaidWeek
            work.project = projectWeek
            work.task = taskWeek
            work.note = noteWeek
            if let moneyEarned = formatter.number(from: moneyEarnedWeek) {
                work.hourlyRate = 0.0
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        case PeriodFilter.month.rawValue:
            work.startDate = viewModel.selectedMonth.startOfMonth()
            work.endDate = viewModel.selectedMonth.endOfMonth()
            work.isPaid = isPaidMonth
            work.project = projectMonth
            work.task = taskMonth
            work.note = noteMonth
            if let moneyEarned = formatter.number(from: moneyEarnedMonth) {
                work.hourlyRate = 0.0
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        case PeriodFilter.year.rawValue:
            work.startDate = viewModel.selectedYear.startOfYear()
            work.endDate = viewModel.selectedYear.endOfYear()
            work.isPaid = isPaidYear
            work.project = projectYear
            work.task = taskYear
            work.note = noteYear
            if let moneyEarned = formatter.number(from: moneyEarnedYear) {
                work.hourlyRate = 0.0
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        default:
            break
        }
        
        saveContext()
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

extension AddWorkTimeView {
    private func setupView() {
        guard let work = selectedWork, let periodType = work.periodType else {
            return
        }
        
        selectedWorkName = work.job?.name
        
        switch periodType {
        case PeriodFilter.day.rawValue:
            dayStartDate = work.startDate
            dayEndDate = work.endDate
            isPaidDay = work.isPaid
            hourlyRateDay = formatFloatToString(from: work.hourlyRate)
            moneyEarnedDay = formatFloatToString(from: work.moneyEarned)
            projectDay = work.project ?? ""
            taskDay = work.task ?? ""
            noteDay = work.note ?? ""
        case PeriodFilter.week.rawValue:
            weekDate = work.startDate
            isPaidWeek = work.isPaid
            moneyEarnedWeek = formatFloatToString(from: work.moneyEarned)
            projectWeek = work.project ?? ""
            taskWeek = work.task ?? ""
            noteWeek = work.note ?? ""
        case PeriodFilter.month.rawValue:
            monthDate = work.startDate
            isPaidMonth = work.isPaid
            moneyEarnedMonth = formatFloatToString(from: work.moneyEarned)
            projectMonth = work.project ?? ""
            taskMonth = work.task ?? ""
            noteMonth = work.note ?? ""
        case PeriodFilter.year.rawValue:
            yearDate = work.startDate
            isPaidYear = work.isPaid
            moneyEarnedYear = formatFloatToString(from: work.moneyEarned)
            projectYear = work.project ?? ""
            taskYear = work.task ?? ""
            noteYear = work.note ?? ""
        default:
            break
        }
    }
    
    private func updateSaveButtonState() {
        let isProperJobSelected = jobs.contains(where: { $0.name == selectedWorkName })
        
        withAnimation(.easeInOut(duration: 0.2)) {
            hourlyRateDay = formatFloatToString(from: jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate)
            isDaySaveButtonEnabled = (!hourlyRateDay.isEmpty || !moneyEarnedDay.isEmpty)
                && isProperJobSelected
            isWeekSaveButtonEnabled = !moneyEarnedWeek.isEmpty && isProperJobSelected
            isMonthSaveButtonEnabled = !moneyEarnedMonth.isEmpty && isProperJobSelected
            isYearSaveButtonEnabled = !moneyEarnedYear.isEmpty && isProperJobSelected
        }
        
        guard let work = selectedWork, let periodType = work.periodType else {
            return
        }
        
        isDaySaveButtonEnabled = false
        isWeekSaveButtonEnabled = false
        isMonthSaveButtonEnabled = false
        isYearSaveButtonEnabled = false

        var hasChanged = false
        
        switch periodType {
        case PeriodFilter.day.rawValue:
            hasChanged = dayStartDate != work.startDate ||
                dayEndDate != work.endDate ||
                isPaidDay != work.isPaid ||
                hourlyRateDay != formatFloatToString(from: work.hourlyRate) ||
                moneyEarnedDay != formatFloatToString(from: work.moneyEarned) ||
                projectDay != work.project ||
                taskDay != work.task ||
                noteDay != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isDaySaveButtonEnabled = (!hourlyRateDay.isEmpty || !moneyEarnedDay.isEmpty)
                    && isProperJobSelected && hasChanged
            }
        case PeriodFilter.week.rawValue:
            hasChanged = weekDate != work.startDate ||
                isPaidWeek != work.isPaid ||
                moneyEarnedWeek != formatFloatToString(from: work.moneyEarned) ||
                projectWeek != work.project ||
                taskWeek != work.task ||
                noteWeek != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isWeekSaveButtonEnabled = !moneyEarnedWeek.isEmpty && isProperJobSelected && hasChanged
            }
        case PeriodFilter.month.rawValue:
            hasChanged = monthDate != work.startDate ||
                isPaidMonth != work.isPaid ||
                moneyEarnedMonth != formatFloatToString(from: work.moneyEarned) ||
                projectMonth != work.project ||
                taskMonth != work.task ||
                noteMonth != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isMonthSaveButtonEnabled = !moneyEarnedMonth.isEmpty && isProperJobSelected && hasChanged
            }
        case PeriodFilter.year.rawValue:
            hasChanged = yearDate != work.startDate ||
                isPaidYear != work.isPaid ||
                moneyEarnedYear != formatFloatToString(from: work.moneyEarned) ||
                projectYear != work.project ||
                taskYear != work.task ||
                noteYear != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isYearSaveButtonEnabled = !moneyEarnedYear.isEmpty && isProperJobSelected && hasChanged
            }
        default:
            break
        }
    }
}

extension AddWorkTimeView {
    private func formatFloatToString(from: Float?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","

        guard let from, let formattedAmount = formatter.string(from: NSNumber(value: from)) else {
            return ""
        }
        
        return formattedAmount
    }
    
    func formatNumberInput(_ value: String) -> String {
        // Remove any characters that aren't digits or a decimal separator
        var filtered = value.filter { "0123456789,.".contains($0) }
                
        // Split by the decimal point
        let components = filtered.split(separator: ",")
        
        // If there are more than two components (more than one decimal point), join the first two components
        if components.count > 2 {
            filtered = components[0] + "," + components[1]
        }
        
        // If there's a decimal part, limit it to two digits
        if let decimalIndex = filtered.firstIndex(of: ",") {
            let decimalPart = filtered.suffix(from: decimalIndex)
            if decimalPart.count > 3 { // Include the decimal point itself, so we check for 3 chars
                filtered = String(filtered.prefix(decimalIndex.utf16Offset(in: filtered) + 3))
            }
        }
        
        return filtered
    }
}

#Preview {
    AddJobView()
}
