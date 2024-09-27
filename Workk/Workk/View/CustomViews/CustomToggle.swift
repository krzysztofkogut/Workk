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
                .fill(isOn ? .black : .gray)
                .frame(width: 50, height: 30)
                .overlay {
                    Circle()
                        .fill(.white)
                        .frame(width: 25, height: 25)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.bouncy, value: isOn)
                }
        }
    }
}
