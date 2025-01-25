//
//  SafeAreaInsetsKey.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//

import SwiftUI

struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.safeAreaInsets ?? .zero).insets
    }
}
