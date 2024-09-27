//
//  YearCard.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/02/2024.
//

import SwiftUI

struct YearCard: View {
    var isSelected: Bool
    var year: Date

    var body: some View {
        VStack(spacing: 0) {
            Text(year.currentYearString)
                .font(year.isThisYear() || isSelected ? .latoBold(size: 16) : .latoRegular(size: 16))
                .foregroundColor(year.isThisYear() || isSelected ? .black : .gray)
        }
    }
}

#Preview {
    YearCard(isSelected: true, year: Date())
}
