//
//  StatusBarBasedController.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/12/2023.
//

import SwiftUI

class StatusBarBasedController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
