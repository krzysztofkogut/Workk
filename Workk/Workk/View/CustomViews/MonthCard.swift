//
//  MonthCard.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/02/2024.
//

import SwiftUI

struct MonthCard: View {
    var isSelected: Bool
    var month: Date
        
    var body: some View {
        VStack(spacing: 0) {
            Text(month.currentYearString)
                .lineLimit(1)
                .font(.latoRegular(size: 12))
                .foregroundColor(.gray)
            
            Text(month.currentMonthString)
                .lineLimit(1)
                .font(month.isThisMonth() || isSelected ? .latoBold(size: 16) : .latoRegular(size: 16))
                .foregroundColor(month.isThisMonth() || isSelected ? .black : .gray)
        }
    }
}

#Preview {
    MonthCard(isSelected: true, month: Date())
}
