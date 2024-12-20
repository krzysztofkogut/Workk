//
//  String+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 16/02/2024.
//

import SwiftUI

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func formatNumberInput() -> String {
        // Get the current decimal separator from the locale
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        
        // Filter out any unwanted characters, allowing only digits and the decimal separator
        var filtered = self.filter { "0123456789\(decimalSeparator)".contains($0) }
        
        // Find the first occurrence of the decimal separator
        if let firstDecimalIndex = filtered.firstIndex(of: Character(decimalSeparator)) {
            // Split the string into integer and decimal parts
            let integerPart = String(filtered.prefix(upTo: firstDecimalIndex))
            let decimalPart = String(filtered.suffix(from: filtered.index(after: firstDecimalIndex)))
            
            // Limit the decimal part to two digits
            let trimmedDecimalPart = String(decimalPart.prefix(2))
            
            // Recombine the integer and decimal parts with the separator
            filtered = integerPart + decimalSeparator + trimmedDecimalPart
        }
        
        // If there are multiple decimal separators, keep only the first valid one
        let components = filtered.split(separator: Character(decimalSeparator), omittingEmptySubsequences: false)
        if components.count > 2 {
            filtered = components[0] + decimalSeparator + components[1]
        }
        
        return filtered
    }
}
