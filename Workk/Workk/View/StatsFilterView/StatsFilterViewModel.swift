//
//  StatsFilterViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/11/2024.
//

import Combine
import StoreKit
import SwiftUI
import Resolver

protocol StatsFilterViewModelProtocol where Self: ObservableObject {
    var weeklyStatsTitle: AttributedString { get }
    var monthlyStatsTitle: AttributedString { get }
    var yearlyStatsTitle: AttributedString { get }
}

final class StatsFilterViewModel: StatsFilterViewModelProtocol {
    
    @Published var iCloudSettings: iCloudSettings = Resolver.resolve()
    
    var weeklyStatsTitle: AttributedString {
        var string = AttributedString("WEEKLY STATISTICS")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthlyStatsTitle: AttributedString {
        var string = AttributedString("MONTHLY STATISTICS")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearlyStatsTitle: AttributedString {
        var string = AttributedString("YEARLY STATISTICS")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
}
