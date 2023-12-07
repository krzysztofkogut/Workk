//
//  FilledButton.swift
//  Workk
//
//  Created by Krzysztof Kogut on 17/11/2023.
//

import SwiftUI

struct FilledButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.latoBold(size: 16))
            .foregroundColor(.white)
    }
}
