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
}
