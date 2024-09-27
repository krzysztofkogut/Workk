//
//  DayPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/02/2024.
//

import SwiftUI

struct DayPicker: View {
    @Binding var selection: Date
    var days: [Date]
    @Namespace private var dayPickerAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            ForEach(days, id: \.self) { day in
                Spacer()
                
                VStack(spacing: 0) {
                    DayCard(isSelected: day.isSameDay(date: selection), day: day)
                    
                    if day.isSameDay(date: selection) {
                        Rectangle()
                            .fill(.blueRibbon)
                            .frame(width: 20, height: 2)
                            .padding(.top, 4)
                            .matchedGeometryEffect(id: "dayPicker", in: dayPickerAnimation)
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 20, height: 2)
                            .padding(.top, 4)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selection = day
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

#Preview {
    @State var selection = Date()
    return DayPicker(selection: $selection, days: Calendar.current.daysOfWeek())
}
