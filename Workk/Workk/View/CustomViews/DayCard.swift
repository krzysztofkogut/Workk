//
//  DayCard.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/02/2024.
//

import SwiftUI

struct DayCard: View {
    var isSelected: Bool
    var day: Date

    var body: some View {
        VStack(spacing: 0) {
            Text(day.currentDayShortString)
                .minimumScaleFactor(0.01)
                .fixedSize(horizontal: true, vertical: false)
                .font(.latoRegular(size: 10))
                .foregroundColor(day.isToday() || isSelected ? .black : .gray)
                .padding(.top, 4)
                .padding(.bottom, 2)

            Text(day.currentDayNumberString)
                .minimumScaleFactor(0.01)
                .fixedSize(horizontal: true, vertical: false)
                .font(day.isToday() || isSelected ? .latoBlack(size: 14) : .latoRegular(size: 14))
                .foregroundColor(day.isToday() || isSelected ? .black : .gray)
        }
        .padding(.top, 2)
    }
}

#Preview {
    return DayCard(isSelected: true, day: Date())
}
