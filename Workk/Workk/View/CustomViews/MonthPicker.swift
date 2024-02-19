//
//  MonthPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/02/2024.
//

import SwiftUI

struct MonthPicker: View {
    @Binding var selection: Date?
    var months: [Date]
    @Namespace private var monthPickerAnimation
    @State private var selectionWidthDict: [Date : CGFloat] = [:]
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(months, id: \.self) { month in
                Spacer()
                
                VStack(spacing: 0) {
                    MonthCard(isSelected: selection == nil ? month.isThisMonth() : month.isSameMonth(date: selection ?? month) , month: month)
                        .onAppear {
                            selectionWidthDict[month] = month.currentMonthString.widthOfString(usingFont: .latoBold(size: 14))
                        }
                    
                    if selection == nil ? month.isThisMonth() : month.isSameMonth(date: selection ?? month) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.persianBlue)
                            .frame(width: selectionWidthDict[month], height: 2)
                            .padding(.top, 4)
                            .matchedGeometryEffect(id: "monthPicker", in: monthPickerAnimation)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.clear)
                            .frame(width: selectionWidthDict[month], height: 2)
                            .padding(.top, 4)
                    }
                }
                .frame(width: 80, alignment: .center)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selection = month
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    @State var selection: Date? = nil
    return MonthPicker(selection: $selection, months: Calendar.current.lastThreeMonths())
}
