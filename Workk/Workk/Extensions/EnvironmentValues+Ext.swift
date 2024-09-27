//
//  EnvironmentValues+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//

import SwiftUI

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}
