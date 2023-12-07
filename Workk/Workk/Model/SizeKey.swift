//
//  SizeKey.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/12/2023.
//

import SwiftUI

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
