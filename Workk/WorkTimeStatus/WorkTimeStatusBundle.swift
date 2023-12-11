//
//  WorkTimeStatusBundle.swift
//  WorkTimeStatus
//
//  Created by Krzysztof Kogut on 11/12/2023.
//

import WidgetKit
import SwiftUI

@main
struct WorkTimeStatusBundle: WidgetBundle {
    var body: some Widget {
        WorkTimeStatus()
        WorkTimeStatusLiveActivity()
    }
}
