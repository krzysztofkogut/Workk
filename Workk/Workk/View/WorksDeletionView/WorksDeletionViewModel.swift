//
//  DeletionViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 09/11/2024.
//

import Combine
import StoreKit
import SwiftUI

protocol WorksDeletionViewModelProtocol where Self: ObservableObject {
    var dayTitle: AttributedString { get }
    var weekTitle: AttributedString { get }
    var monthTitle: AttributedString { get }
    var yearTitle: AttributedString { get }
}

final class WorksDeletionViewModel: WorksDeletionViewModelProtocol {
    
    var dayTitle: AttributedString {
        var string = AttributedString("day_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var weekTitle: AttributedString {
        var string = AttributedString("week_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthTitle: AttributedString {
        var string = AttributedString("month_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearTitle: AttributedString {
        var string = AttributedString("year_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
}
