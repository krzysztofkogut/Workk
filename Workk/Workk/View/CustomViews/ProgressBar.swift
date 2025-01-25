//
//  ProgressBar.swift
//  Workk
//
//  Created by Krzysztof Kogut on 04/12/2023.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var percent: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 6)
                .cornerRadius(3)
                .foregroundColor(.wildSand)

            Rectangle()
                .frame(width: calculateWidth(), height: 6)
                .cornerRadius(3)
                .foregroundColor(percent < 1 ? .blackWhite : .bottleGreen)
        }
    }

    func calculateWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width - 64

        return width * min(percent, 1.0)
    }

    func roundToTwoDecimalsIfNecessary(_ value: CGFloat) -> CGFloat {
        let roundedToFour = (value * 10000).rounded() / 10000
        let roundedToThree = (value * 1000).rounded() / 1000

        // If the fourth decimal place changes the number, return the two-decimal version
        return roundedToFour == roundedToThree ? roundedToThree : (roundedToThree * 10).rounded() / 10
    }
}

#Preview {
    @State var percent: CGFloat = 0.5
    return ProgressBar(percent: $percent)
}
