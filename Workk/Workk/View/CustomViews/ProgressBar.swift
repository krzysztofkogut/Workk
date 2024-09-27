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
                .foregroundColor(.athensGray)

            Rectangle()
                .frame(width: calculateWidth(), height: 6)
                .cornerRadius(3)
                .foregroundColor(.black)
        }
    }

    func calculateWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width - 80

        return width * percent
    }
}

#Preview {
    @State var percent: CGFloat = 0.5
    return ProgressBar(percent: $percent)
}
