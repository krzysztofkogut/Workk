//
//  WeekCard.swift
//  Workk
//
//  Created by Krzysztof Kogut on 16/02/2024.
//

import SwiftUI

struct WeekCard: View {
    var isSelected: Bool
    var week: Date

    var body: some View {
        VStack(spacing: 0) {
            Text(week.currentYearString)
                .lineLimit(1)
                .font(.latoRegular(size: 12))
                .foregroundColor(.gray)

            Text(week.currentWeekString)
                .lineLimit(1)
                .font(week.isThisWeek() || isSelected ? .latoBold(size: 16) : .latoRegular(size: 16))
                .foregroundColor(week.isThisWeek() || isSelected ? .blackWhite : .gray)
        }
    }
}

#Preview {
    WeekCard(isSelected: true, week: Date())
}
