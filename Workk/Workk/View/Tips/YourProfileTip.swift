//
//  YourProfileTip.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/02/2025.
//

import SwiftUI
import TipKit

struct YourProfileTip: Tip {
    @Parameter
    static var hasSeenOnboarding: Bool = false
    
    var title: Text {
        Text("your_profile_tip_title".localized)
            .font(.latoBold(size: 16))
            .foregroundStyle(.blackWhite)
    }

    var message: Text? {
        Text("your_profile_tip_message".localized)
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
