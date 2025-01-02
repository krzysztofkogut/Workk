//
//  StatsFilterView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/11/2024.
//

import Resolver
import SwiftUI

struct StatsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject private var viewModel: StatsFilterViewModel = Resolver.resolve()
    
    @State var isDaysForWeekSelected: Bool = true
    @State var isWeekForWeekSelected: Bool = true
    @State var isDaysForMonthSelected: Bool = true
    @State var isWeeksForMonthSelected: Bool = true
    @State var isMonthForMonthSelected: Bool = true
    @State var isDaysForYearSelected: Bool = true
    @State var isWeeksForYearSelected: Bool = true
    @State var isMonthsForYearSelected: Bool = true
    @State var isYearForYearSelected: Bool = true
    
    @Binding var weekFilters: Set<PeriodFilter> //= [.day, .week]
    @Binding var monthFilters: Set<PeriodFilter> //= [.day, .week, .month]
    @Binding var yearFilters: Set<PeriodFilter> //= [.day, .week, .month, .year]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("filters_title".localized)
                    .font(.latoBlack(size: 28))
                    .foregroundColor(.blackWhite)
                    .padding(.bottom, 8)
                
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.weeklyStatsTitle)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 16)
                    
                    FilterOptionView(title: "days_title".localized, isSelected: $isDaysForWeekSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if weekFilters.contains(.day), weekFilters.count > 1 {
                                    weekFilters.remove(.day)
                                    isDaysForWeekSelected = false
                                } else {
                                    weekFilters.insert(.day)
                                    isDaysForWeekSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "week_title".localized, isSelected: $isWeekForWeekSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if weekFilters.contains(.week), weekFilters.count > 1 {
                                    weekFilters.remove(.week)
                                    isWeekForWeekSelected = false
                                } else {
                                    weekFilters.insert(.week)
                                    isWeekForWeekSelected = true
                                }
                            }
                        }
                    
                    Text(viewModel.monthlyStatsTitle)
                        .font(.latoBlack(size: 14))
                        .foregroundStyle(.gray)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 16)
                    
                    FilterOptionView(title: "days_title".localized, isSelected: $isDaysForMonthSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if monthFilters.contains(.day), monthFilters.count > 1 {
                                    monthFilters.remove(.day)
                                    isDaysForMonthSelected = false
                                } else {
                                    monthFilters.insert(.day)
                                    isDaysForMonthSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "weeks_title".localized, isSelected: $isWeeksForMonthSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if monthFilters.contains(.week), monthFilters.count > 1 {
                                    monthFilters.remove(.week)
                                    isWeeksForMonthSelected = false
                                } else {
                                    monthFilters.insert(.week)
                                    isWeeksForMonthSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "month_title".localized, isSelected: $isMonthForMonthSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if monthFilters.contains(.month), monthFilters.count > 1 {
                                    monthFilters.remove(.month)
                                    isMonthForMonthSelected = false
                                } else {
                                    monthFilters.insert(.month)
                                    isMonthForMonthSelected = true
                                }
                            }
                        }
                    
                    Text(viewModel.yearlyStatsTitle)
                        .font(.latoBlack(size: 14))
                        .foregroundStyle(.gray)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 16)
                    
                    FilterOptionView(title: "days_title".localized, isSelected: $isDaysForYearSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if yearFilters.contains(.day), yearFilters.count > 1 {
                                    yearFilters.remove(.day)
                                    isDaysForYearSelected = false
                                } else {
                                    yearFilters.insert(.day)
                                    isDaysForYearSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "weeks_title".localized, isSelected: $isWeeksForYearSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if yearFilters.contains(.week), yearFilters.count > 1 {
                                    yearFilters.remove(.week)
                                    isWeeksForYearSelected = false
                                } else {
                                    yearFilters.insert(.week)
                                    isWeeksForYearSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "months_title".localized, isSelected: $isMonthsForYearSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if yearFilters.contains(.month), yearFilters.count > 1 {
                                    yearFilters.remove(.month)
                                    isMonthsForYearSelected = false
                                } else {
                                    yearFilters.insert(.month)
                                    isMonthsForYearSelected = true
                                }
                            }
                        }
                    
                    FilterOptionView(title: "year_title".localized, isSelected: $isYearForYearSelected)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                if yearFilters.contains(.year), yearFilters.count > 1 {
                                    yearFilters.remove(.year)
                                    isYearForYearSelected = false
                                } else {
                                    yearFilters.insert(.year)
                                    isYearForYearSelected = true
                                }
                            }
                        }
                }
                .padding(.top, 24)
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            isDaysForWeekSelected = weekFilters.contains(.day)
            isWeekForWeekSelected = weekFilters.contains(.week)
            isDaysForMonthSelected = monthFilters.contains(.day)
            isWeeksForMonthSelected = monthFilters.contains(.week)
            isMonthForMonthSelected = monthFilters.contains(.month)
            isDaysForYearSelected = yearFilters.contains(.day)
            isWeeksForYearSelected = yearFilters.contains(.week)
            isMonthsForYearSelected = yearFilters.contains(.month)
            isYearForYearSelected = yearFilters.contains(.year)
        }
    }
}
