//
//  Image+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 31/10/2024.
//

import SwiftUI

extension Image {
    func addSymbolEffect(isSelected: Bool) -> some View {
        if #available(iOS 17.0, *) {
            return self
                .symbolEffect(.bounce.byLayer.down, value: isSelected)
        } else {
            return self
        }
    }
}
