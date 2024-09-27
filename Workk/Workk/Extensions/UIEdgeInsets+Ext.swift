//
//  UIEdgeInsets+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//

import SwiftUI

extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
