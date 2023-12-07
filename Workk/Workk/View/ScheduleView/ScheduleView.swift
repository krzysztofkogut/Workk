//
//  ScheduleView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 20/10/2023.
//

import SwiftUI

struct ScheduleView: View {
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let monthYearFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.monthYearFormatter = DateFormatter(dateFormat: "MMMM yyyy", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.athensGray)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false){
                VStack(spacing: 24) {
                    CalendarView(
                        calendar: calendar,
                        date: $selectedDate,
                        content: { date in
                            Button(action: { selectedDate = date }) {
                                Text("00")
                                    .padding(8)
                                    .foregroundColor(.clear)
        //                            .background(
        //                                calendar.isDate(date, inSameDayAs: selectedDate) ? Color.cranberry
        //                                    : calendar.isDateInToday(date) ? .persianBlue
        //                                : .cornflowerBlue
        //                            )
                                    .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(calendar.isDate(date, inSameDayAs: selectedDate) ? .cranberry : calendar.isDateInToday(date) ? .gray : .athensGray, lineWidth: 6)
                                            )
                                    .cornerRadius(8)
                                    .accessibilityHidden(true)
                                    .overlay(
                                        Text(dayFormatter.string(from: date))
                                            .foregroundColor(.black)
                                    )
                                
                            }
                        },
                        trailing: { date in
                            Text(dayFormatter.string(from: date))
                                .font(FontManager.body)
                                .foregroundColor(.secondary)
                        },
                        header: { date in
                            Text(weekDayFormatter.string(from: date))
                                .font(FontManager.body)
                        },
                        title: { date in
                            HStack {
                                Text(monthYearFormatter.string(from: date))
                                    .font(.headline)
                                    .padding()
                                Spacer()
                                Button {
                                    withAnimation {
                                        guard let newDate = calendar.date(
                                            byAdding: .month,
                                            value: -1,
                                            to: selectedDate
                                        ) else {
                                            return
                                        }

                                        selectedDate = newDate
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
                                Button {
                                    withAnimation {
                                        guard let newDate = calendar.date(
                                            byAdding: .month,
                                            value: 1,
                                            to: selectedDate
                                        ) else {
                                            return
                                        }

                                        selectedDate = newDate
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
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white)
                    }
                    
                    CalendarView(
                        calendar: calendar,
                        date: $selectedDate,
                        content: { date in
                            Button(action: { selectedDate = date }) {
                                Text("00")
                                    .padding(8)
                                    .foregroundColor(.clear)
        //                            .background(
        //                                calendar.isDate(date, inSameDayAs: selectedDate) ? Color.cranberry
        //                                    : calendar.isDateInToday(date) ? .persianBlue
        //                                : .cornflowerBlue
        //                            )
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(calendar.isDate(date, inSameDayAs: selectedDate) ? .cranberry : calendar.isDateInToday(date) ? .gray : .athensGray, lineWidth: 6)
                                    )
                                    .cornerRadius(8)
                                    .accessibilityHidden(true)
                                    .overlay(
                                        Text(dayFormatter.string(from: date))
                                            .foregroundColor(.black)
                                    )
                                
                            }
                        },
                        trailing: { date in
                            Text(dayFormatter.string(from: date))
                                .font(FontManager.body)
                                .foregroundColor(.secondary)
                        },
                        header: { date in
                            Text(weekDayFormatter.string(from: date))
                                .font(FontManager.body)
                        },
                        title: { date in
                            HStack {
                                Text(monthYearFormatter.string(from: date))
                                    .font(.headline)
                                    .padding()
                                Spacer()
                                Button {
                                    withAnimation {
                                        guard let newDate = calendar.date(
                                            byAdding: .month,
                                            value: -1,
                                            to: selectedDate
                                        ) else {
                                            return
                                        }

                                        selectedDate = newDate
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
                                Button {
                                    withAnimation {
                                        guard let newDate = calendar.date(
                                            byAdding: .month,
                                            value: 1,
                                            to: selectedDate
                                        ) else {
                                            return
                                        }

                                        selectedDate = newDate
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
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ScheduleView(calendar: Calendar.current)
}
