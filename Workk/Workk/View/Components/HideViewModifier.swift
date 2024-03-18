//
//  HideViewModifier.swift
//  Workk
//
//  Created by Krzysztof Kogut on 21/02/2024.
//

import SwiftUI

struct HideViewModifier: ViewModifier {
    let isHidden: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if isHidden {
            EmptyView()
        } else {
            content
        }
    }
}
