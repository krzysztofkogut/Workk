//
//  CustomSubscriptionToggle.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/01/2025.
//

import Resolver
import SwiftUI

struct CustomSubscriptionToggle: View {
    @Binding var isOn: Bool
    @Binding var showSubsciptionView: Bool
    var subscriptionActive: Bool

    var body: some View {
        Button(action: {
            withAnimation(.bouncy) {
                if subscriptionActive {
                    isOn.toggle()
                } else {
                    showSubsciptionView = true
                }
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
