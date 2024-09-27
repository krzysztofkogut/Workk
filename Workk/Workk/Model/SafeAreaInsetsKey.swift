//
//  SafeAreaInsetsKey.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//

import SwiftUI

struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}
