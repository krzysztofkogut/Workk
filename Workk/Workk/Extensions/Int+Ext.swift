//
//  Int+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 17/03/2024.
//

import Foundation

extension Int {
    var timeString: String {
        self < 10 ? "0\(self)" : "\(self)"
    }
}
