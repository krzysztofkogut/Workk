//
//  RequiredFieldAddWorkTip.swift
//  Workk
//
//  Created by Krzysztof Kogut on 04/02/2025.
//

import SwiftUI
import TipKit

struct RequiredFieldsAddWorkTip: Tip {
    var title: Text {
        Text("required_fields_add_work_tip_title".localized)
            .font(.latoBold(size: 16))
            .foregroundStyle(.blackWhite)
    }

    var message: Text? {
        Text("required_fields_add_work_tip_message".localized)
            .font(.latoRegular(size: 14))
            .foregroundStyle(.gray)
    }
    
    var options: [TipOption] {
        [Tips.MaxDisplayCount(1)]
    }
}
