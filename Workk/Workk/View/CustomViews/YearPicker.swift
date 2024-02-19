//
//  YearPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/02/2024.
//

import SwiftUI

struct YearPicker: View {
    @Binding var selection: Date?
    var years: [Date]
    @Namespace private var yearPickerAnimation
    @State private var selectionWidthDict: [Date : CGFloat] = [:]
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(years, id: \.self) { year in
                Spacer()
                
                VStack(spacing: 0) {
                    YearCard(isSelected: selection == nil ? year.isThisYear() : year.isSameYear(date: selection ?? year) , year: year)
                        .onAppear {
                            selectionWidthDict[year] = year.currentYearString.widthOfString(usingFont: .latoBold(size: 14))
                        }
                    
                    if selection == nil ? year.isThisYear() : year.isSameYear(date: selection ?? year) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.persianBlue)
                            .frame(width: selectionWidthDict[year], height: 2)
                            .padding(.top, 4)
                            .matchedGeometryEffect(id: "yearPicker", in: yearPickerAnimation)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.clear)
                            .frame(width: selectionWidthDict[year], height: 2)
                            .padding(.top, 4)
                    }
                }
                .frame(width: 50, alignment: .center)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selection = year
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    @State var selection: Date? = nil
    return YearPicker(selection: $selection, years: Calendar.current.lastFourYears())
}
