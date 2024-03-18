//
//  StatsView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import Charts
import SwiftUI

struct StatsView: View {
    @State var selection: String? = "Day"
    @State var showAddNewWorkView: Bool = false
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var currentTab: String = "7 Days"
    @State var currentActiveItem: SiteView?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    DropDownPicker(selection: $selection,
                                   addNewOption: $showAddNewWorkView,
                                   hint: "Day",
                                   options: ["Day", "Week", "Month", "Year"],
                                   backgroundColor: .wildSand)
                    
                    Spacer()
                }
                
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Money earned")
                            .font(FontManager.title)
                            .foregroundColor(Color.aluminium)
                        
                        Picker("", selection: $currentTab) {
                            Text("7 Days")
                                .tag("7 Days")
                            Text("Week")
                                .tag("Week")
                            Text("Month")
                                .tag("Month")
                        }
                        .font(FontManager.body)
                        .pickerStyle(.segmented)
                        .padding(.leading, 20)
                    }
                    
                    let totalValue = sampleAnalytics.reduce(0.0) { partialResult, item in
                        item.moneyEarned + partialResult
                    }
                    if let currentActiveItem = currentActiveItem {
                        Text(currentActiveItem.moneyEarned.stringFormat + "$")
                            .font(FontManager.headline_2)
                    } else {
                        Text(totalValue.stringFormat + "$")
                            .font(FontManager.headline_2)
                    }
                    
                    AnimatedChart()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.wildSand)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .onChange(of: currentTab) { newValue in
                sampleAnalytics = sample_analytics
                if newValue != " 7 Days" {
                    for (index, _) in sampleAnalytics.enumerated() {
                        sampleAnalytics[index].moneyEarned = .random(in: 1500...10000)
                    }
                }
                
                animateChart(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = sampleAnalytics.max { $1.moneyEarned > $0.moneyEarned }?.moneyEarned ?? 0
        
        Chart {
            ForEach(sampleAnalytics) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Money", item.animate ? item.moneyEarned : 0)
                )
                .foregroundStyle(Color.persianBlue.gradient)
                .cornerRadius(4)
                
                if let currentActiveItem, currentActiveItem.id == item.id {
                    RuleMark(x: .value("Day", currentActiveItem.day, unit: .day))
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [5], dashPhase: 5))
//                        .lineStyle(.init(lineWidth: 0))
                        .annotation(position: .top) {
//                            VStack(alignment: .center, spacing: 6) {
//                                Text("Money")
//                                    .font(FontManager.body)
//                                    .foregroundColor(.gray)
//                                Text(currentActiveItem.moneyEarned.stringFormat + "$")
//                                    .font(FontManager.title)
//                            }
//                            .padding(.horizontal, 6)
//                            .padding(.vertical, 6)
//                            .background {
//                                RoundedRectangle(cornerRadius: 6, style: .continuous)
//                                    .fill(.white.shadow(.drop(radius: 2)))
//                            }
                            Circle()
                        }
                }
            }
        }
        .chartYScale(domain: 0...(max + 300))
        .chartYAxis(.hidden)
        .chartXAxis
        {
            AxisMarks(values: .stride(by: .day))
            { date in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    let day = calendar.component(.day, from: date)
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        calendar.component(.day, from: item.day) == day
                                    }) {
                                        self.currentActiveItem = currentItem
                                    }
                                }
                            }.onEnded { _ in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 120)
        .onAppear {
            animateChart()
        }
    }
    
    func animateChart(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
            withAnimation(fromChange ? .easeInOut(duration: 0.8).delay(Double(index) * 0.03) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8).delay(Double(index) * 0.05)) {
                    sampleAnalytics[index].animate = true
                }
//            }
        }
    }
}

extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        } else if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        } else {
            return String(format: "%.0f", self)
        }
    }
}

#Preview {
    StatsView()
}
