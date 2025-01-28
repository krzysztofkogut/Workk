//
//  ProfileView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 11/11/2024.
//

import Resolver
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("iCloudSyncEnabled") private var isICloudSyncEnabled: Bool = false
    @AppStorage("dailyNotificationEnabled") private var isDailyNotificationEnabled: Bool = true
    @AppStorage("dailyNotificationTimeInterval") private var dailyNotificationTimeInterval: Double = Date.now.setDateAtSpecificHourAndMinute(hour: 8, minute: 0)?.timeIntervalSince1970 ?? Date.now.timeIntervalSince1970
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @AppStorage("dailyMoneyGoal") private var dailyMoneyGoal: String = ""
    @AppStorage("weeklyMoneyGoal") private var weeklyMoneyGoal: String = ""
    @AppStorage("monthlyMoneyGoal") private var monthlyMoneyGoal: String = ""
    @AppStorage("yearlyMoneyGoal") private var yearlyMoneyGoal: String = ""
    
    @AppStorage("dailyHoursGoal") private var dailyHoursGoal: String = ""
    @AppStorage("weeklyHoursGoal") private var weeklyHoursGoal: String = ""
    @AppStorage("monthlyHoursGoal") private var monthlyHoursGoal: String = ""
    @AppStorage("yearlyHoursGoal") private var yearlyHoursGoal: String = ""
    
    @ObservedObject private var viewModel: ProfileViewModel = Resolver.resolve()
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    @State private var showJobsDeletionView = false
    @State private var showSubscriptionPlanView = false
    @State private var showICloudAlertSheet = false
    
    @State private var dailyNotificationTime: Date = .now
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.blackWhite)
                            .font(.title)
                    }
                }
                .padding(.top, 16)
                
                HStack {
                    Text("your_profile_title".localized)
                        .font(.latoBlack(size: 28))
                        .foregroundColor(.blackWhite)
                        .padding(.bottom, 8)
                    
                    Spacer()
                }
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 4) {
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
                        .padding(.top, 16)
                        .hide(if: userSubscriptionViewModel.subscriptionActive)
                        
                        Text(viewModel.jobsTitle)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 16)
                            .padding(.top, 32)
                            .padding(.bottom, 4)
                            .onTapGesture {
                                UIApplication.shared.dismissKeyboard()
                            }
                        
                        HStack {
                            Text("jobs_list_title".localized)
                                .font(.latoRegular(size: 16))
                                .foregroundColor(.blackWhite)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundColor(.blackWhite)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(.whiteTheme)
                        .cornerRadius(12)
                        .onTapGesture {
                            viewModel.showJobListView()
                        }
                        
                        Text(viewModel.goalsTitle)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 16)
                            .padding(.top, 32)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .center, spacing: 0) {
                            Text("money_goals_title")
                                .font(.latoBold(size: 20))
                                .foregroundColor(.blackWhite)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                            
                            HStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(viewModel.dailyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField(currencyIdentifier.uppercased(), text: $dailyMoneyGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text(currencyIdentifier.uppercased())
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: dailyMoneyGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.weeklyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                                                        
                                    ZStack(alignment: .top) {
                                        TextField(currencyIdentifier.uppercased(), text: $weeklyMoneyGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text(currencyIdentifier.uppercased())
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: weeklyMoneyGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                            }
                            .padding(.top, 16)
                            
                            HStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(viewModel.monthlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField(currencyIdentifier.uppercased(), text: $monthlyMoneyGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text(currencyIdentifier.uppercased())
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: monthlyMoneyGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.yearlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField(currencyIdentifier.uppercased(), text: $yearlyMoneyGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text(currencyIdentifier.uppercased())
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: yearlyMoneyGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .background(.whiteTheme, in: .rect(cornerRadius: 12))
                        .background(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                        )
                        .padding(.bottom, 4)
                        
                        VStack(alignment: .center, spacing: 0) {
                            Text("hours_goals_title".localized)
                                .font(.latoBold(size: 20))
                                .foregroundColor(.blackWhite)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                            
                            HStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(viewModel.dailyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField("hours_title".localized, text: $dailyHoursGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text("hours_title".localized)
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: dailyHoursGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.weeklyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField("hours_title".localized, text: $weeklyHoursGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text("hours_title".localized)
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: weeklyHoursGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                            }
                            .padding(.top, 8)
                            
                            HStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(viewModel.monthlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    ZStack(alignment: .top) {
                                        TextField("hours_title".localized, text: $monthlyHoursGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text("hours_title".localized)
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: monthlyHoursGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.yearlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                                                        
                                    ZStack(alignment: .top) {
                                        TextField("hours_title".localized, text: $yearlyHoursGoal)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.decimalPad)
                                            .font(.latoRegular(size: 16))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 32)
                                            .background(.wildSand, in: .rect(cornerRadius: 12))
                                        
                                        Text("hours_title".localized)
                                            .font(.latoBold(size: 12))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.top, 16)
                                            .hide(if: yearlyHoursGoal.isEmpty)
                                    }
                                    .fixedSize(horizontal: false, vertical: false)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .background(.whiteTheme, in: .rect(cornerRadius: 12))
                        .background(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                        )
                    }
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.dismissKeyboard()
                            }
                    )
                    
                    Text(viewModel.currencyTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                    
                    TextField(currencyIdentifier, text: $currencyIdentifier)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.blackWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    Text("currency_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text(viewModel.iCloudTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                                        
                    HStack(spacing: 0) {
                        Text("icloud_title".localized)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        CustomSubscriptionToggle(isOn: $isICloudSyncEnabled,
                                                 showSubsciptionView: $showSubscriptionPlanView,
                                                 subscriptionActive: userSubscriptionViewModel.subscriptionActive)
                            .onChange(of: isICloudSyncEnabled) { newValue in
                                if userSubscriptionViewModel.subscriptionActive {
                                    PersistenceManager.shared = PersistenceManager(useCloud: newValue)
                                    showICloudAlertSheet = true
                                }
                            }
                    }
                    .padding(.horizontal, 16)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    Text("icloud_sync_profile_description".localized)
                        .font(.nunitoSemiBold(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text(viewModel.dailyNotificationTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                    
                    HStack(spacing: 0) {
                        Text("notifications_enabled_title".localized)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        CustomToggle(isOn: $isDailyNotificationEnabled)
                    }
                    .padding(.horizontal, 16)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        Text("daily_notification_time_title".localized)
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackWhite)
                        
                        DateTextField(date: $dailyNotificationTime, components: [.hourAndMinute]) { date in
                            let customDateFormatter: DateFormatter = {
                                let formatter = DateFormatter()
                                formatter.calendar = Calendar.current
                                formatter.locale = Locale.current
                                formatter.timeStyle = .short
                                return formatter
                            }()
                            
                            return customDateFormatter.string(from: date)
                        }
                        .foregroundStyle(.blackWhite)
                        .presentationBackground(.clear)
                        .multilineTextAlignment(.trailing)
                        .font(.latoBold(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.whiteTheme, in: .rect(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let threshold: CGFloat = 10
                        let velocityThreshold: CGFloat = 50
                        
                        if value.translation.height > threshold,
                           value.predictedEndTranslation.height > velocityThreshold
                        {
                            UIApplication.shared.dismissKeyboard()
                        }
                    }
            )
            .onAppear {
                dailyNotificationTime = Date(timeIntervalSince1970: dailyNotificationTimeInterval)
            }
            .onChange(of: dailyMoneyGoal) { newValue in
                dailyMoneyGoal = newValue.formatNumberInput()
            }
            .onChange(of: dailyHoursGoal) { newValue in
                dailyHoursGoal = newValue.formatNumberInput()
            }
            .onChange(of: weeklyMoneyGoal) { newValue in
                weeklyMoneyGoal = newValue.formatNumberInput()
            }
            .onChange(of: weeklyHoursGoal) { newValue in
                weeklyHoursGoal = newValue.formatNumberInput()
            }
            .onChange(of: monthlyMoneyGoal) { newValue in
                monthlyMoneyGoal = newValue.formatNumberInput()
            }
            .onChange(of: monthlyHoursGoal) { newValue in
                monthlyHoursGoal = newValue.formatNumberInput()
            }
            .onChange(of: yearlyMoneyGoal) { newValue in
                yearlyMoneyGoal = newValue.formatNumberInput()
            }
            .onChange(of: yearlyHoursGoal) { newValue in
                yearlyHoursGoal = newValue.formatNumberInput()
            }
            .onChange(of: currencyIdentifier) { newValue in
                // Keep only letters and limit to 3 characters
                currencyIdentifier = newValue.uppercased().filter { $0.isLetter }
                if currencyIdentifier.count > 3 {
                    currencyIdentifier = String(currencyIdentifier.prefix(3))
                }
            }
            .onChange(of: dailyNotificationTime) { newValue in
                dailyNotificationTimeInterval = newValue.timeIntervalSince1970
                
                if isDailyNotificationEnabled {
                    viewModel.cancelDailyNotification()
                    viewModel.scheduleDailyNotification(at: newValue)
                }
            }
            .onChange(of: isDailyNotificationEnabled) { newValue in
                newValue ?
                    viewModel.scheduleDailyNotification(at: dailyNotificationTime) : viewModel.cancelDailyNotification()
            }
            .fullScreenCover(isPresented: $showSubscriptionPlanView) {
                SubscriptionPlanView()
            }
            .sheet(isPresented: $showJobsDeletionView) {
                JobsDeletionView()
                    .background(.wildSand)
            }
            .floatingBottomSheet(isPresented: $showICloudAlertSheet) {
                SheetView(
                    title: "icloud_title".localized,
                    content: "icloud_sync_description".localized,
                    button1: .init(
                        content: "ok_title".localized,
                        tint: .whiteBlack,
                        foreground: .blackWhite,
                        action: {
                            showICloudAlertSheet = false
                        }))
                        .presentationDetents([.height(250)])
            }
            .withProfileRoutes()
            .background {
                Color(.wildSand)
                    .ignoresSafeArea()
            }
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
