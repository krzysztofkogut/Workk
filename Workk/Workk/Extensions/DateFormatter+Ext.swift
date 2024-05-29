//
//  DateFormatter+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 31/03/2024.
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}
