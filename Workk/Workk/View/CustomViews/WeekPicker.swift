//
//  WeekPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 16/02/2024.
//

import SwiftUI

struct WeekPicker: View {
    @Binding var selection: Date?
    var weeks: [Date]
    @Namespace private var weekPickerAnimation
    @State private var selectionWidthDict: [Date: CGFloat] = [:]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weeks, id: \.self) { week in
                Spacer()

                VStack(spacing: 0) {
                    WeekCard(isSelected: selection == nil ? week.isThisWeek() : week.isSameWeek(date: selection ?? week), week: week)
                        .onAppear {
                            selectionWidthDict[week] = week.currentWeekString.widthOfString(usingFont: .latoRegular(size: 14))
                        }

                    if selection == nil ? week.isThisMonth() : week.isSameWeek(date: selection ?? week) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.persianBlue)
                            .frame(width: selectionWidthDict[week], height: 2)
                            .padding(.top, 4)
                            .matchedGeometryEffect(id: "weekPicker", in: weekPickerAnimation)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.clear)
                            .frame(width: selectionWidthDict[week], height: 2)
                            .padding(.top, 4)
                    }
                }
                .frame(width: 120, alignment: .center)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selection = week
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    @State var selection: Date? = nil
    return WeekPicker(selection: $selection, weeks: Calendar.current.lastTwoWeeks())
}
