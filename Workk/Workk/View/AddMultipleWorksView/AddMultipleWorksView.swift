//
//  AddMultipleWorksView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/02/2025.
//

import SwiftUI
import Resolver

struct AddMultipleWorksView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
    
    @StateObject private var scheduleViewModel: ScheduleViewModel = Resolver.resolve()
    @StateObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    @StateObject private var adManager: InterstitialAdManager = Resolver.resolve()
    
    @Binding var selectedJob: Job?
    @Binding var selectedWorkName: String?
    
    @State private var showSubscriptionPlanView: Bool = false
    
    @State private var overtimeDescription = "overtime_description".localized
    @State private var isDropDownError: Bool = false
    @State private var showAddJobView: Bool = false
    
    @State private var dayStartDate: Date = .now
    @State private var dayEndDate: Date = .now
    @State private var dayStartHour: Date = .now
    @State private var dayEndHour: Date = .now
    @State private var isPaidDay = false
    @State private var isHourlyRateDay = false
    @State private var hourlyRateDay: String = ""
    @State private var moneyEarnedDay: String = ""
    @State private var isOvertimeDay = false
    @State private var overtimePercentageDay: String = "150"
    @State private var projectDay: String = ""
    @State private var taskDay: String = ""
    @State private var noteDay: String = ""
    @State private var isDaySaveButtonEnabled = false
    @State private var isDayValidationError = false
    
    @State private var selectedDays: Set<Int> = [2,3,4,5,6]
    @State private var chips: [Chip] = [
        Chip(dayNumber: 2, name: "monday_title".localized), Chip(dayNumber: 3, name: "tuesday_title".localized),
        Chip(dayNumber: 4, name: "wednesday_title".localized), Chip(dayNumber: 5, name: "thursday_title".localized),
        Chip(dayNumber: 6, name: "friday_title".localized), Chip(dayNumber: 7, name: "saturday_title".localized),
        Chip(dayNumber: 1, name: "sunday_title".localized)]

    @Namespace var animation
    
    var daysOfWeekTitle: AttributedString {
        var string = AttributedString("days_of_week_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var overTimeMultiplierDay: Float {
        isOvertimeDay ? (overtimePercentageDay.floatValue() / 100) : 1.0
    }
    
    var saveButtonStateKey: String {
        return "\(dayStartDate)\(dayEndDate)\(dayStartHour)\(dayEndHour)\(hourlyRateDay)\(moneyEarnedDay)\(overtimePercentageDay)\(String(describing: selectedWorkName))\(isHourlyRateDay)\(isPaidDay)\(isOvertimeDay)"
    }
    
    var body: some View {
        VStack {
            HStack {
                DropDownPicker(selection: $selectedWorkName,
                               addNewOption: $showAddJobView,
                               showSubscriptionPlan: $showSubscriptionPlanView,
                               isError: $isDropDownError,
                               hint: "select_title".localized,
                               options: jobs.compactMap { $0.name },
                               backgroundColor: .whiteTheme,
                               maxWidth: 220)
                .popoverTip(DropdownPickerAddWorkTip(), arrowEdge: .bottom)
                
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
            
            Text("add_multiple_works_title".localized)
                .font(.latoBlack(size: 28))
                .foregroundColor(.blackWhite)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    HStack(spacing: 0) {
                        Text("start_date_title".localized)
                            .foregroundStyle(.blackWhite)
                            .font(.latoRegular(size: 16))
                        
                        GraphicalDateTextField(date: $dayStartDate, components: [.date]) { date in
                            date.dayPickerOnlyDateString
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
                        
                        GraphicalDateTextField(date: $dayEndDate, components: [.date]) { date in
                            date.dayPickerOnlyDateString
                        }
                        .foregroundStyle(.blackWhite)
                        .multilineTextAlignment(.trailing)
                        .font(.latoBold(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        Text("Start hour")
                            .foregroundStyle(.blackWhite)
                            .font(.latoRegular(size: 16))
                        
                        DateTextField(date: $dayStartHour, components: [.hourAndMinute]) { date in
                            date.dayPickerOnlyHourString
                        }
                        .foregroundStyle(.blackWhite)
                        .multilineTextAlignment(.trailing)
                        .font(.latoBold(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        Text("End hour")
                            .foregroundStyle(.blackWhite)
                            .font(.latoRegular(size: 16))
                        
                        DateTextField(date: $dayEndHour, components: [.hourAndMinute]) { date in
                            date.dayPickerOnlyHourString
                        }
                        .foregroundStyle(.blackWhite)
                        .multilineTextAlignment(.trailing)
                        .font(.latoBold(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    Text(daysOfWeekTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                    
                    GeometryReader { geometry in
                        let availableWidth = geometry.size.width
                        ChipsView(fix3Count: false, containerWidth: availableWidth, chips: chips) { chip in
                            Button {
                                if selectedDays.contains(chip.dayNumber) {
                                    selectedDays.remove(chip.dayNumber)
                                } else {
                                    selectedDays.insert(chip.dayNumber)
                                }
                            } label : {
                                Text(chip.name)
                                    .font(.latoBold(size: 12))
                                    .foregroundStyle(selectedDays.contains(chip.dayNumber) ? .whiteBlack : .blackWhite)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(selectedDays.contains(chip.dayNumber) ? .blackWhite : .whiteTheme, in: .capsule)
                                    .matchedGeometryEffect(id: chip.id, in: animation)
                            }
                        }
                        .frame(width: availableWidth)
                    }
                    .frame(minHeight: 80, maxHeight: 140)
                    .padding(8)
                    
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        Text(currencyIdentifier.uppercased())
                            .foregroundStyle(.blackWhite)
                            .font(.latoBold(size: 16))
                            .padding(.trailing, 16)
                    }
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    .popoverTip(RequiredFieldsAddWorkTip(), arrowEdge: .bottom)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cranberry, lineWidth: 2)
                            .hide(if: !isDayValidationError || isDaySaveButtonEnabled)
                    }
                    
                    HStack(spacing: 0) {
                        Text("overtime_title".localized)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        CustomToggle(isOn: $isOvertimeDay)
                    }
                    .padding(.horizontal, 16)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        TextField("overtime_title".localized, text: $overtimePercentageDay)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        Text("%")
                            .foregroundStyle(.blackWhite)
                            .font(.latoBold(size: 16))
                            .padding(.trailing, 16)
                    }
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cranberry, lineWidth: 2)
                            .hide(if: !isDayValidationError || isDaySaveButtonEnabled)
                    }
                    .hide(if: !isOvertimeDay)
                    
                    Text(overtimeDescription)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 2)
                        .padding(.horizontal, 16)
                        .hide(if: !isOvertimeDay)
                    
                    HStack(spacing: 0) {
                        TextField("project_title".localized, text: $projectDay)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        Text("project_title".localized)
                            .foregroundStyle(.blackWhite)
                            .font(.latoBold(size: 16))
                            .padding(.trailing, 16)
                            .hide(if: projectDay.isEmpty)
                    }
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        TextField("task_title".localized, text: $taskDay)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        Text("task_title".localized)
                            .foregroundStyle(.blackWhite)
                            .font(.latoBold(size: 16))
                            .padding(.trailing, 16)
                            .hide(if: taskDay.isEmpty)
                    }
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    MultilineTextField(placeHolder: noteDay.isEmpty ? "note_title".localized : noteDay, text: $noteDay)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(height: 150)
                        .background(.whiteTheme, in: .rect(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            self.dayStartDate = .now.updatingYearMonthAndDay(from: scheduleViewModel.selectedDay) ?? .now
            self.dayEndDate = .now.updatingYearMonthAndDay(from: scheduleViewModel.selectedDay) ?? .now
                        
            if !userSubscriptionViewModel.subscriptionActive {
                showAd()
            }
            
            if selectedWorkName == "all_title".localized {
                withAnimation(.bouncy(duration: 0.4)) {
                    selectedWorkName = nil
                }
            }
        }
        .onDisappear {
            if selectedWorkName == nil {
                withAnimation(.bouncy(duration: 0.4)) {
                    selectedWorkName = "all_title".localized
                }
            }
        }
        .onChange(of: dayStartDate) { _, newValue in
            if newValue > dayEndDate {
                dayEndDate = newValue
            }
            
            updateSaveButtonState()
        }
        .onChange(of: dayEndDate) { _, newValue in
            if newValue < dayStartDate {
                DispatchQueue.main.async {
                    dayEndDate = dayStartDate
                }
            }
            
            updateSaveButtonState()
        }
        .onChange(of: dayStartHour) { _, newValue in
            if newValue > dayEndHour {
                dayEndHour = newValue
            }
            
            updateSaveButtonState()
        }
        .onChange(of: dayEndHour) { _, newValue in
            if newValue < dayStartHour {
                DispatchQueue.main.async {
                    dayEndHour = dayStartHour
                }
            }
            
            updateSaveButtonState()
        }
        .onChange(of: selectedWorkName) { _, newValue in
            if hourlyRateDay.isEmpty && isHourlyRateDay {
                hourlyRateDay = jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate.formatFloatToString() ?? ""
            }
            
            isDropDownError = newValue == "all_title".localized
            
            updateSaveButtonState()
        }
        .onChange(of: isHourlyRateDay) { _, newValue in
            if hourlyRateDay.isEmpty && newValue {
                hourlyRateDay = jobs.first(where: { $0.name == selectedWorkName })?.hourlyRate.formatFloatToString() ?? ""
            } else if !newValue {
                hourlyRateDay = ""
            }
            
            updateSaveButtonState()
        }
        .onChange(of: saveButtonStateKey) { updateSaveButtonState() }
        .background(
            Color.wildSand
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
        )
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
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button {
                    guard isDaySaveButtonEnabled else {
                        withAnimation(.spring(duration: 0.2)) {
                            isDayValidationError = true
                            isDropDownError = selectedWorkName == "all_title".localized || selectedWorkName == nil
                        }
                        return
                    }
                    generateWorkEntries()
                    dismiss()
                } label: {
                    Text("save_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(isDaySaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
                }
                
                Text("add_work_conditions_decription".localized)
                    .font(.nunitoSemiBold(size: 12))
                    .foregroundStyle(.whiteBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 16)
                    .hide(if: isDaySaveButtonEnabled)
            }
            .padding(.bottom, 16)
        }
    }
}

extension AddMultipleWorksView {
    private func updateSaveButtonState() {
        let isProperJobSelected = jobs.contains(where: { $0.name == selectedWorkName })
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isDaySaveButtonEnabled = (isHourlyRateDay && !hourlyRateDay.isEmpty || !isHourlyRateDay && !moneyEarnedDay.isEmpty)
                && isProperJobSelected && (!isOvertimeDay || !overtimePercentageDay.isEmpty)
        }
    }
}

extension AddMultipleWorksView {
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension AddMultipleWorksView {
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

extension AddMultipleWorksView {
    private func generateWorkEntries() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
            
        let calendar = Calendar.init(identifier: .iso8601)
        var date = dayStartDate
        
        while date <= dayEndDate || date.isSameDay(date: dayEndDate) {
            let components = calendar.dateComponents([.weekday], from: date)
            if let weekday = components.weekday, selectedDays.contains(weekday) {
                let newItem = Work(context: viewContext)
                newItem.id = UUID()
                newItem.periodType = PeriodFilter.day.rawValue
                newItem.job = jobs.first(where: { $0.name == selectedWorkName })
                newItem.startDate = combineDateWithTime(date: date, time: dayStartHour)
                newItem.endDate = combineDateWithTime(date: date, time: dayEndHour)
                newItem.isPaid = isPaidDay
                newItem.isHourlyRateDay = isHourlyRateDay
                newItem.isOvertime = isOvertimeDay
                newItem.overtimePercentage = overtimePercentageDay.floatValue()
                newItem.project = projectDay
                newItem.task = taskDay
                newItem.note = noteDay
                newItem.hoursWorked = dayStartHour.timeDifferenceInHours(to: dayEndHour)
                if isHourlyRateDay, let rate = formatter.number(from: hourlyRateDay) {
                    newItem.hourlyRate = rate.floatValue * overTimeMultiplierDay
                    newItem.moneyEarned = rate.floatValue * dayStartHour.timeDifferenceInHours(to: dayEndHour) * overTimeMultiplierDay
                } else if !isHourlyRateDay, let moneyEarned = formatter.number(from: moneyEarnedDay) {
                    newItem.hourlyRate = moneyEarned.floatValue / dayStartHour.timeDifferenceInHours(to: dayEndHour) * overTimeMultiplierDay
                    newItem.moneyEarned = moneyEarned.floatValue * overTimeMultiplierDay
                } else {
                    newItem.hourlyRate = 0.0
                    newItem.moneyEarned = 0.0
                }
                
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save work entity: \(error)")
                }
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
    }
    
    private func combineDateWithTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)) ?? date
    }
}
