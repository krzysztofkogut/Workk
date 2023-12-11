//
//  WorkTimeStatusAttributes.swift
//  Workk
//
//  Created by Krzysztof Kogut on 11/12/2023.
//

import ActivityKit
import SwiftUI

struct WorkTimeStatusAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var workTime: Date
        var emoji: String
    }
    
    var workName: String
}
