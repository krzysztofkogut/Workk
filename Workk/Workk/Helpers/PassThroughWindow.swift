//
//  PassThroughWindow.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/12/2023.
//

import SwiftUI

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
