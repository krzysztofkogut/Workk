//
//  OffsetKey.swift
//  Workk
//
//  Created by Krzysztof Kogut on 09/01/2024.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
