//
//  CustomToggle.swift
//  Workk
//
//  Created by Krzysztof Kogut on 07/09/2024.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            withAnimation(.bouncy) {
                isOn.toggle()
            }
        }) {
            RoundedRectangle(cornerRadius: 16)
                .fill(isOn ? .blackWhite : .gray)
                .frame(width: 50, height: 30)
                .overlay {
                    Circle()
                        .fill(.whiteTheme)
                        .frame(width: 26, height: 26)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.bouncy, value: isOn)
                }
        }
    }
}
