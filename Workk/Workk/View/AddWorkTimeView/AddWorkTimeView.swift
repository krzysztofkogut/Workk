//
//  AddWorkTimeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/09/2024.
//

import Resolver
import SwiftUI

enum AddWorkTimePlace: String, CaseIterable {
    case home
    case schedule
}

struct AddWorkTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Namespace var filterAnimation
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
    
    @ObservedObject private var homeViewModel: HomeViewModel = Resolver.resolve()
    @ObservedObject private var scheduleViewModel: ScheduleViewModel = Resolver.resolve()
    
    let addWorkTimePlace: AddWorkTimePlace
    @Binding var selectedWork: Work?
    @Binding var selectedFilter: PeriodFilter
    @Binding var selectedWorkName: String?

    @State var selectedJob: Job? = nil
    
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
    @State private var hoursWorkedWeek: String = ""
    @State private var projectWeek: String = ""
    @State private var taskWeek: String = ""
    @State private var noteWeek: String = ""
    @State private var isWeekSaveButtonEnabled = false
    
    @State private var monthDate: Date = .now
    @State private var isPaidMonth = false
    @State private var moneyEarnedMonth: String = ""
    @State private var hoursWorkedMonth: String = ""
    @State private var projectMonth: String = ""
    @State private var taskMonth: String = ""
    @State private var noteMonth: String = ""
    @State private var isMonthSaveButtonEnabled = false
    
    @State private var yearDate: Date = .now
    @State private var isPaidYear = false
    @State private var moneyEarnedYear: String = ""
    @State private var hoursWorkedYear: String = ""
    @State private var projectYear: String = ""
    @State private var taskYear: String = ""
    @State private var noteYear: String = ""
    @State private var isYearSaveButtonEnabled = false
    
    var selectedDay: Date {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.selectedDay
        case .schedule:
            scheduleViewModel.selectedDay
        }
    }
    
    var selectedWeek: Date {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.selectedWeek
        case .schedule:
            scheduleViewModel.selectedWeek
        }
    }
    
    var selectedMonth: Date {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.selectedMonth
        case .schedule:
            scheduleViewModel.selectedMonth
        }
    }
    
    var selectedYear: Date {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.selectedYear
        case .schedule:
            scheduleViewModel.selectedYear
        }
    }
            
    var body: some View {
        VStack {
            HStack {
                DropDownPicker(selection: $selectedWorkName,
                               addNewOption: $showAddJobView,
                               hint: "select_title".localized,
                               options: jobs.compactMap { $0.name },
                               backgroundColor: .whiteTheme,
                               maxWidth: 220)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blackWhite)
                        .font(.title)
                }
            }
            .zIndex(1000)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Text(selectedWork == nil ? "add_work_time_title".localized : "update_work_time_title".localized)
                .font(.latoBlack(size: 28))
                .foregroundColor(.blackWhite)
                .padding(.bottom, 32)
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            periodFilterBar
                .padding(.bottom, 8)
                .hide(if: selectedWork != nil)
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
                        
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
            self.dayStartDate = .now.updatingMonthAndDay(from: selectedDay) ?? .now
            self.dayEndDate = .now.updatingMonthAndDay(from: selectedDay) ?? .now
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
            hourlyRateDay = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: moneyEarnedDay) { newValue in
            moneyEarnedDay = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: moneyEarnedWeek) { newValue in
            moneyEarnedWeek = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: moneyEarnedMonth) { newValue in
            moneyEarnedMonth = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: moneyEarnedYear) { newValue in
            moneyEarnedYear = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: hoursWorkedWeek) { newValue in
            hoursWorkedWeek = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: hoursWorkedMonth) { newValue in
            hoursWorkedMonth = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: hoursWorkedYear) { newValue in
            hoursWorkedYear = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .onChange(of: selectedWorkName) { _ in
            if hourlyRateDay.isEmpty && isHourlyRateDay {
                hourlyRateDay = jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate.formatFloatToString() ?? ""
            }
            
            updateSaveButtonState()
        }
        .onChange(of: isHourlyRateDay) { newValue in
            if hourlyRateDay.isEmpty && newValue {
                hourlyRateDay = jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate.formatFloatToString() ?? ""
            } else if !newValue {
                hourlyRateDay = ""
            }
            
            updateSaveButtonState()
        }
        .onChange(of: selectedFilter) { _ in UIApplication.shared.dismissKeyboard() }
        .onChange(of: isPaidDay) { _ in updateSaveButtonState() }
        .onChange(of: projectDay) { _ in updateSaveButtonState() }
        .onChange(of: taskDay) { _ in updateSaveButtonState() }
        .onChange(of: noteDay) { _ in updateSaveButtonState() }
        .onChange(of: weekDate) { _ in updateSaveButtonState() }
        .onChange(of: hoursWorkedWeek) { _ in updateSaveButtonState() }
        .onChange(of: isPaidWeek) { _ in updateSaveButtonState() }
        .onChange(of: projectWeek) { _ in updateSaveButtonState() }
        .onChange(of: taskWeek) { _ in updateSaveButtonState() }
        .onChange(of: noteWeek) { _ in updateSaveButtonState() }
        .onChange(of: monthDate) { _ in updateSaveButtonState() }
        .onChange(of: hoursWorkedMonth) { _ in updateSaveButtonState() }
        .onChange(of: isPaidMonth) { _ in updateSaveButtonState() }
        .onChange(of: projectMonth) { _ in updateSaveButtonState() }
        .onChange(of: taskMonth) { _ in updateSaveButtonState() }
        .onChange(of: noteMonth) { _ in updateSaveButtonState() }
        .onChange(of: yearDate) { _ in updateSaveButtonState() }
        .onChange(of: hoursWorkedYear) { _ in updateSaveButtonState() }
        .onChange(of: isPaidYear) { _ in updateSaveButtonState() }
        .onChange(of: projectYear) { _ in updateSaveButtonState() }
        .onChange(of: taskYear) { _ in updateSaveButtonState() }
        .onChange(of: noteYear) { _ in updateSaveButtonState() }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let threshold: CGFloat = 20
                    let velocityThreshold: CGFloat = 30
                            
                    if value.translation.height > threshold,
                       value.predictedEndTranslation.height > velocityThreshold
                    {
                        UIApplication.shared.dismissKeyboard()
                    }
                }
        )
        .fullScreenCover(isPresented: $showAddJobView) {
            AddJobView(selectedJob: $selectedJob)
        }
    }
    
    var addDayWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("start_date_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    DateTextField(date: $dayStartDate, components: [.date, .hourAndMinute]) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MMM yyyy, HH:mm"
                        return formatter.string(from: date)
                    }
                    .foregroundStyle(.blackWhite)
                    .multilineTextAlignment(.trailing)
                    .font(.latoBold(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("end_date_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    DateTextField(date: $dayEndDate, components: [.date, .hourAndMinute]) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MMM yyyy, HH:mm"
                        return formatter.string(from: date)
                    }
                    .foregroundStyle(.blackWhite)
                    .multilineTextAlignment(.trailing)
                    .font(.latoBold(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("is_paid_title".localized)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidDay)
                }
                .padding(.horizontal, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("hourly_rate_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isHourlyRateDay)
                }
                .padding(.horizontal, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField(isHourlyRateDay ? "hourly_rate_title".localized : "money_earned_title".localized, text: isHourlyRateDay ? $hourlyRateDay : $moneyEarnedDay)
                        .foregroundStyle(.blackWhite)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("PLN")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 16))
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("project_title".localized, text: $projectDay)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("task_title".localized, text: $taskDay)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "note_title".localized, text: $noteDay)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("save_title".localized)
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
            }
            .disabled(!isDaySaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isDaySaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
    
    var addWeekWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 4) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: backwardToLastWeek) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        WeekCard(isSelected: true, week: selectedWeek)
                        
                        Spacer()
                        
                        Button(action: forwardToNextWeek) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 12)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("is_paid_title".localized)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidWeek)
                }
                .padding(.horizontal, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("money_earned_title".localized, text: $moneyEarnedWeek)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("PLN")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 16))
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("hours_worked_title".localized, text: $hoursWorkedWeek)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("h")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("project_title".localized, text: $projectWeek)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("task_title".localized, text: $taskWeek)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "note_title".localized, text: $noteWeek)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("save_title".localized)
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
            }
            .disabled(!isWeekSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isWeekSaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
    
    var addMonthWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 4) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: backwardToLastMonth) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        MonthCard(isSelected: true, month: selectedMonth)
                        
                        Spacer()
                        
                        Button(action: forwardToNextMonth) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 12)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("is_paid_title".localized)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidMonth)
                }
                .padding(.horizontal, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("money_earned_title".localized, text: $moneyEarnedMonth)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("PLN")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 16))
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("hours_worked_title".localized, text: $hoursWorkedMonth)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("h")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("project_title".localized, text: $projectMonth)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("task_title".localized, text: $taskMonth)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "note_title".localized, text: $noteMonth)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("save_title".localized)
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
            }
            .disabled(!isMonthSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isMonthSaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
    
    var addYearWorkTimeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 4) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: backwardToLastYear) {
                            Image(systemName: "chevron.left")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        YearCard(isSelected: true, year: selectedYear)
                        
                        Spacer()
                        
                        Button(action: forwardToNextYear) {
                            Image(systemName: "chevron.right")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 18)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    Text("is_paid_title".localized)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    CustomToggle(isOn: $isPaidYear)
                }
                .padding(.horizontal, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("money_earned_title".localized, text: $moneyEarnedYear)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Text("PLN")
                        .foregroundStyle(.blackWhite)
                        .font(.latoBold(size: 16))
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                HStack(spacing: 0) {
                    TextField("hours_worked_title".localized, text: $hoursWorkedYear)
                        .keyboardType(.decimalPad)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    Spacer()
                    
                    Text("h")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.trailing, 16)
                }
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("project_title".localized, text: $projectYear)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                TextField("task_title".localized, text: $taskYear)
                    .font(.latoRegular(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                
                MultilineTextField(placeHolder: "note_title".localized, text: $noteYear)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(height: 150)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedWork == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("save_title".localized)
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
            }
            .disabled(!isYearSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isYearSaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
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
                        .foregroundColor(selectedFilter == item ? .blackWhite : .gray)
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
            newItem.hoursWorked = dayStartDate.timeDifferenceInHours(to: dayEndDate)
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
            newItem.startDate = selectedWeek.startOfWeek()
            newItem.endDate = selectedWeek.endOfWeek()
            newItem.isPaid = isPaidWeek
            newItem.project = projectWeek
            newItem.task = taskWeek
            newItem.note = noteWeek
            
            if let hoursWorked = formatter.number(from: hoursWorkedWeek) {
                newItem.hoursWorked = hoursWorked.floatValue
            } else {
                newItem.hoursWorked = 0.0
            }
            
            if let moneyEarned = formatter.number(from: moneyEarnedWeek) {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        case .month:
            newItem.startDate = selectedMonth.startOfMonth()
            newItem.endDate = selectedMonth.endOfMonth()
            newItem.isPaid = isPaidMonth
            newItem.project = projectMonth
            newItem.task = taskMonth
            newItem.note = noteMonth
            
            if let hoursWorked = formatter.number(from: hoursWorkedMonth) {
                newItem.hoursWorked = hoursWorked.floatValue
            } else {
                newItem.hoursWorked = 0.0
            }
            
            if let moneyEarned = formatter.number(from: moneyEarnedMonth) {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = moneyEarned.floatValue
            } else {
                newItem.hourlyRate = 0.0
                newItem.moneyEarned = 0.0
            }
        case .year:
            newItem.startDate = selectedYear.startOfYear()
            newItem.endDate = selectedYear.endOfYear()
            newItem.isPaid = isPaidYear
            newItem.project = projectYear
            newItem.task = taskYear
            newItem.note = noteYear
            
            if let hoursWorked = formatter.number(from: hoursWorkedYear) {
                newItem.hoursWorked = hoursWorked.floatValue
            } else {
                newItem.hoursWorked = 0.0
            }
            
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
        guard let work = selectedWork else {
            return
        }
        
        let periodType = work.periodType
        
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
            work.startDate = selectedWeek.startOfWeek()
            work.endDate = selectedWeek.endOfWeek()
            work.isPaid = isPaidWeek
            work.project = projectWeek
            work.task = taskWeek
            work.note = noteWeek
            
            if let hoursWorked = formatter.number(from: hoursWorkedWeek) {
                work.hoursWorked = hoursWorked.floatValue
            } else {
                work.hoursWorked = 0.0
            }
            
            if let moneyEarned = formatter.number(from: moneyEarnedWeek) {
                work.hourlyRate = 0.0
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        case PeriodFilter.month.rawValue:
            work.startDate = selectedMonth.startOfMonth()
            work.endDate = selectedMonth.endOfMonth()
            work.isPaid = isPaidMonth
            work.project = projectMonth
            work.task = taskMonth
            work.note = noteMonth
            
            if let hoursWorked = formatter.number(from: hoursWorkedMonth) {
                work.hoursWorked = hoursWorked.floatValue
            } else {
                work.hoursWorked = 0.0
            }
            
            if let moneyEarned = formatter.number(from: moneyEarnedMonth) {
                work.hourlyRate = 0.0
                work.moneyEarned = moneyEarned.floatValue
            } else {
                work.hourlyRate = 0.0
                work.moneyEarned = 0.0
            }
        case PeriodFilter.year.rawValue:
            work.startDate = selectedYear.startOfYear()
            work.endDate = selectedYear.endOfYear()
            work.isPaid = isPaidYear
            work.project = projectYear
            work.task = taskYear
            work.note = noteYear
            
            if let hoursWorked = formatter.number(from: hoursWorkedYear) {
                work.hoursWorked = hoursWorked.floatValue
            } else {
                work.hoursWorked = 0.0
            }
            
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
        guard let work = selectedWork else {
            return
        }
        
        let periodType = work.periodType
        
        selectedWorkName = work.job?.name
        
        switch periodType {
        case PeriodFilter.day.rawValue:
            dayStartDate = work.startDate
            dayEndDate = work.endDate
            isPaidDay = work.isPaid
            hourlyRateDay = work.hourlyRate.formatFloatToString()
            moneyEarnedDay = work.moneyEarned.formatFloatToString()
            projectDay = work.project ?? ""
            taskDay = work.task ?? ""
            noteDay = work.note ?? ""
        case PeriodFilter.week.rawValue:
            weekDate = work.startDate
            isPaidWeek = work.isPaid
            moneyEarnedWeek = work.moneyEarned.formatFloatToString()
            hoursWorkedWeek = work.hoursWorked.formatFloatToString()
            projectWeek = work.project ?? ""
            taskWeek = work.task ?? ""
            noteWeek = work.note ?? ""
        case PeriodFilter.month.rawValue:
            monthDate = work.startDate
            isPaidMonth = work.isPaid
            moneyEarnedMonth = work.moneyEarned.formatFloatToString()
            hoursWorkedMonth = work.hoursWorked.formatFloatToString()
            projectMonth = work.project ?? ""
            taskMonth = work.task ?? ""
            noteMonth = work.note ?? ""
        case PeriodFilter.year.rawValue:
            yearDate = work.startDate
            isPaidYear = work.isPaid
            moneyEarnedYear = work.moneyEarned.formatFloatToString()
            hoursWorkedYear = work.hoursWorked.formatFloatToString()
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
            /*hourlyRateDay = formatFloatToString(from: jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate)*/ // tutaj do zmiany
            isDaySaveButtonEnabled = (!hourlyRateDay.isEmpty || !moneyEarnedDay.isEmpty)
                && isProperJobSelected
            isWeekSaveButtonEnabled = !moneyEarnedWeek.isEmpty && !hoursWorkedWeek.isEmpty && isProperJobSelected
            isMonthSaveButtonEnabled = !moneyEarnedMonth.isEmpty && !hoursWorkedMonth.isEmpty && isProperJobSelected
            isYearSaveButtonEnabled = !moneyEarnedYear.isEmpty && !hoursWorkedYear.isEmpty && isProperJobSelected
        }
        
        guard let work = selectedWork else {
            return
        }
        
        isDaySaveButtonEnabled = false
        isWeekSaveButtonEnabled = false
        isMonthSaveButtonEnabled = false
        isYearSaveButtonEnabled = false
        
        let periodType = work.periodType

        var hasChanged = false
        
        switch periodType {
        case PeriodFilter.day.rawValue:
            hasChanged = dayStartDate != work.startDate ||
                dayEndDate != work.endDate ||
                isPaidDay != work.isPaid ||
                hourlyRateDay != work.hourlyRate.formatFloatToString() ||
                moneyEarnedDay != work.moneyEarned.formatFloatToString() ||
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
                moneyEarnedWeek != work.moneyEarned.formatFloatToString() ||
                hoursWorkedWeek != work.hoursWorked.formatFloatToString() ||
                projectWeek != work.project ||
                taskWeek != work.task ||
                noteWeek != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isWeekSaveButtonEnabled = !moneyEarnedWeek.isEmpty &&
                    !hoursWorkedWeek.isEmpty &&
                    isProperJobSelected &&
                    hasChanged
            }
        case PeriodFilter.month.rawValue:
            hasChanged = monthDate != work.startDate ||
                isPaidMonth != work.isPaid ||
                moneyEarnedMonth != work.moneyEarned.formatFloatToString() ||
                hoursWorkedMonth != work.hoursWorked.formatFloatToString() ||
                projectMonth != work.project ||
                taskMonth != work.task ||
                noteMonth != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isMonthSaveButtonEnabled = !moneyEarnedMonth.isEmpty &&
                !hoursWorkedWeek.isEmpty &&
                isProperJobSelected &&
                hasChanged
            }
        case PeriodFilter.year.rawValue:
            hasChanged = yearDate != work.startDate ||
                isPaidYear != work.isPaid ||
                moneyEarnedYear != work.moneyEarned.formatFloatToString() ||
                hoursWorkedYear != work.hoursWorked.formatFloatToString() ||
                projectYear != work.project ||
                taskYear != work.task ||
                noteYear != work.note ||
                selectedWorkName != work.job?.name
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isYearSaveButtonEnabled = !moneyEarnedYear.isEmpty &&
                !hoursWorkedYear.isEmpty &&
                isProperJobSelected &&
                hasChanged
            }
        default:
            break
        }
    }
}

extension AddWorkTimeView {
    private func backwardToLastWeek() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.backwardToLastWeek()
        case .schedule:
            scheduleViewModel.backwardToLastWeek()
        }
    }
    
    private func forwardToNextWeek() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.forwardToNextWeek()
        case .schedule:
            scheduleViewModel.forwardToNextWeek()
        }
    }
    
    private func backwardToLastMonth() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.backwardToLastMonth()
        case .schedule:
            scheduleViewModel.backwardToLastMonth()
        }
    }
    
    private func forwardToNextMonth() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.forwardToNextMonth()
        case .schedule:
            scheduleViewModel.forwardToNextMonth()
        }
    }
    
    private func backwardToLastYear() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.backwardToLastYear()
        case .schedule:
            scheduleViewModel.backwardToLastYear()
        }
    }
    
    private func forwardToNextYear() {
        switch addWorkTimePlace {
        case .home:
            homeViewModel.forwardToNextYear()
        case .schedule:
            scheduleViewModel.forwardToNextYear()
        }
    }
}

//extension AddWorkTimeView {
//    private func formatNumberInput(_ value: String) -> String {
//        // Get the current decimal separator from the locale
//        let decimalSeparator = Locale.current.decimalSeparator ?? "."
//        
//        // Determine the characters to filter, including the localized decimal separator
//        var filtered = value.filter { "0123456789\(decimalSeparator)".contains($0) }
//        
//        // Split by the decimal separator
//        let components = filtered.split(separator: Character(decimalSeparator))
//        
//        // If there are more than two components (more than one decimal separator), join the first two components
//        if components.count > 2 {
//            filtered = components[0] + decimalSeparator + components[1]
//        }
//        
//        // If there's a decimal part, limit it to two digits
//        if let decimalIndex = filtered.firstIndex(of: Character(decimalSeparator)) {
//            let decimalPart = filtered.suffix(from: decimalIndex)
//            if decimalPart.count > (1 + 2) { // Include the decimal separator itself, so we check for 3 chars
//                filtered = String(filtered.prefix(decimalIndex.utf16Offset(in: filtered) + 3))
//            }
//        }
//        
//        return filtered
//    }
//}
