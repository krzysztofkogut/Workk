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
        var workStartTime: Date {
            Calendar.current.date(
                byAdding: .second,
                value: -Int(workTimeInterval),
              to: Date()) ?? Date()
        }
        var workTimeInterval: TimeInterval = 0
    }
    
    var workName: String
}
