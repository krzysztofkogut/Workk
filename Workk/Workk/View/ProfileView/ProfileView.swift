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
    
    @ObservedObject private var viewModel: ProfileViewModel = Resolver.resolve()
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    
    @State private var showJobsDeletionView = false
    @State private var showSubscriptionPlanView = false
    
    @State private var dailyMoneyGoal: String = "" // User settings
    @State private var weeklyMoneyGoal: String = "" // User settings
    @State private var monthlyMoneyGoal: String = "" // User settings
    @State private var yearlyMoneyGoal: String = "" // User settings
    
    @State private var dailyHoursGoal: String = "" // User settings
    @State private var weeklyHoursGoal: String = "" // User settings
    @State private var monthlyHoursGoal: String = "" // User settings
    @State private var yearlyHoursGoal: String = "" // User settings
    
    @State private var currency: String = Locale.current.currency?.identifier ?? "" // User settings
    
    @State private var isDailyNotificationEnabled = true // User settings
    @State private var dailyNotificationTime: Date = .now // User settings
    
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
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(.wildSand, in: .rect(cornerRadius: 30))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                        }
                        .padding(16)
                        .background(.blackWhite, in: .rect(cornerRadius: 12))
                        .padding(.vertical, 16)
                        
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
                                    
                                    TextField(currency.uppercased(), text: $dailyMoneyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.weeklyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField(currency.uppercased(), text: $weeklyMoneyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                            }
                            .padding(.top, 16)
                            
                            HStack(spacing: 8) {
                                VStack {
                                    Text(viewModel.monthlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField(currency.uppercased(), text: $monthlyMoneyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                                
                                VStack {
                                    Text(viewModel.yearlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField(currency.uppercased(), text: $yearlyMoneyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
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
                                    
                                    TextField("hours_title".localized, text: $dailyHoursGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                                
                                VStack(spacing: 4) {
                                    Text(viewModel.weeklyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField("hours_title".localized, text: $weeklyHoursGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                            }
                            .padding(.top, 8)
                            
                            HStack(spacing: 8) {
                                VStack {
                                    Text(viewModel.monthlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField("hours_title".localized, text: $monthlyHoursGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                                
                                VStack {
                                    Text(viewModel.yearlyGoalTitle)
                                        .foregroundStyle(.gray)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            UIApplication.shared.dismissKeyboard()
                                        }
                                    
                                    TextField("hours_title".localized, text: $yearlyHoursGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
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
                    
                    TextField(viewModel.currencyCode?.uppercased() ?? "", text: $currency)
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
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            return formatter.string(from: date)
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
            .safeAreaInset(edge: .bottom) {
                Button {
                    dismiss()
                    saveContext()
                } label: {
                    Text("save_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.blackWhite, in: .rect(cornerRadius: 18))
                .padding(.bottom, 30)
            }
            .onChange(of: dailyNotificationTime) { newValue in
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
