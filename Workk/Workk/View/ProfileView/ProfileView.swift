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
    
    @State private var dailyGoal: String = "" // User settings
    @State private var weeklyGoal: String = "" // User settings
    @State private var monthlyGoal: String = "" // User settings
    @State private var yearlyGoal: String = "" // User settings
    
    @State private var currency: String = "PLN" // User settings
    
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
                            .foregroundColor(.black)
                            .font(.title)
                    }
                }
                .padding(.top, 16)
                
                HStack {
                    Text("Your profile")
                        .font(.latoBlack(size: 28))
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                    
                    Spacer()
                }
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 4) {
                        VStack(spacing: 8) {
                            Text("Odblokuj złożone statystyki, synchronizację iCloud, export danych \ni usuń reklamy")
                                .font(.latoBlack(size: 16))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding([.top, .horizontal], 24)
                            
                            Text(viewModel.workkPremiumTitle)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                            
                            Button {
                                showSubscriptionPlanView = true
                            } label: {
                                Text("Wypróbuj 7 dni za darmo")
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.black)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(.wildSand, in: .rect(cornerRadius: 30))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                        }
                        .padding(16)
                        .background(.black, in: .rect(cornerRadius: 12))
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
                            Text("Jobs list")
                                .font(.latoRegular(size: 16))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(.white)
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
                            Text("Money goals")
                                .font(.latoBold(size: 20))
                                .foregroundColor(.black)
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
                                    
                                    TextField(currency.uppercased(), text: $dailyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField(currency.uppercased(), text: $weeklyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField(currency.uppercased(), text: $monthlyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField(currency.uppercased(), text: $yearlyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .background(.white, in: .rect(cornerRadius: 12))
                        .background(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                        )
                        .padding(.bottom, 4)
                        
                        VStack(alignment: .center, spacing: 0) {
                            Text("Hours goals")
                                .font(.latoBold(size: 20))
                                .foregroundColor(.black)
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
                                    
                                    TextField("hours", text: $dailyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField("hours", text: $weeklyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField("hours", text: $monthlyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
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
                                    
                                    TextField("hours", text: $yearlyGoal)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .font(.nunitoSemiBold(size: 16))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 32)
                                        .background(.wildSand, in: .rect(cornerRadius: 12))
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .background(.white, in: .rect(cornerRadius: 12))
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
                    
                    TextField(currency.uppercased(), text: $currency)
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .background(.white, in: .rect(cornerRadius: 12))
                    
                    Text("Changing currency will not convert the money earned")
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
                        Text("Notifications enabled")
                            .font(.latoRegular(size: 16))
                            .padding(.vertical, 18)
                        
                        Spacer()
                        
                        CustomToggle(isOn: $isDailyNotificationEnabled)
                    }
                    .padding(.horizontal, 16)
                    .background(.white, in: .rect(cornerRadius: 12))
                    
                    HStack(spacing: 0) {
                        Text("Daily notification time")
                            .font(.latoRegular(size: 16))
                        
                        DateTextField(date: $dailyNotificationTime, components: [.hourAndMinute]) { date in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            return formatter.string(from: date)
                        }
                        .presentationBackground(.clear)
                        .multilineTextAlignment(.trailing)
                        .font(.latoBold(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(.white, in: .rect(cornerRadius: 12))
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
                    Text("Save")
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.black, in: .rect(cornerRadius: 18))
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
