//
//  Float+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 27/09/2024.
//

import Foundation

extension Float {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        } else if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        } else {
            return String(format: "%.2f", self)
        }
    }
    
    func formatFloatToString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        guard let formattedAmount = formatter.string(from: NSNumber(value: self)) else {
            return ""
        }
        
        return formattedAmount
    }
}
