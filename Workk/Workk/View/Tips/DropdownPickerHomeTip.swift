//
//  DropdownPickerHomeTip.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/02/2025.
//

import SwiftUI
import TipKit

struct DropdownPickerHomeTip: Tip {
    @Parameter
    static var hasSeenOnboarding: Bool = false
    
    var title: Text {
        Text("dropdown_picker_home_tip_title".localized)
            .font(.latoBold(size: 16))
            .foregroundStyle(.blackWhite)
    }

    var message: Text? {
        Text("dropdown_picker_home_tip_message".localized)
            .font(.latoRegular(size: 14))
            .foregroundStyle(.gray)
    }
    
    var options: [TipOption] {
        [Tips.MaxDisplayCount(1)]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasSeenOnboarding) { $0 == true } 
        ]
    }
}
