//
//  GoalsView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 16/01/2025.
//

import SwiftUI

struct GoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @AppStorage("dailyMoneyGoal") private var dailyMoneyGoal: String = ""
    @AppStorage("weeklyMoneyGoal") private var weeklyMoneyGoal: String = ""
    @AppStorage("monthlyMoneyGoal") private var monthlyMoneyGoal: String = ""
    @AppStorage("yearlyMoneyGoal") private var yearlyMoneyGoal: String = ""
    
    @AppStorage("dailyHoursGoal") private var dailyHoursGoal: String = ""
    @AppStorage("weeklyHoursGoal") private var weeklyHoursGoal: String = ""
    @AppStorage("monthlyHoursGoal") private var monthlyHoursGoal: String = ""
    @AppStorage("yearlyHoursGoal") private var yearlyHoursGoal: String = ""
    
    var dailyGoalTitle: AttributedString {
        var string = AttributedString("daily_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var weeklyGoalTitle: AttributedString {
        var string = AttributedString("weekly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthlyGoalTitle: AttributedString {
        var string = AttributedString("monthly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearlyGoalTitle: AttributedString {
        var string = AttributedString("yearly_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var body: some View {
        VStack(spacing: 8) {
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
            .padding(.bottom, 8)
            
            Text("setup_goal_title".localized)
                .font(.latoBlack(size: 28))
                .foregroundColor(.blackWhite)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                 
            Text("setup_goal_description".localized)
                .font(.nunitoSemiBold(size: 12))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
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
                            Text(dailyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(weeklyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(monthlyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(yearlyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(dailyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(weeklyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(monthlyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
                            Text(yearlyGoalTitle)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
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
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 16)
        .background(
            Color.wildSand
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
        )
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
    }
}

#Preview {
    GoalsView()
}
