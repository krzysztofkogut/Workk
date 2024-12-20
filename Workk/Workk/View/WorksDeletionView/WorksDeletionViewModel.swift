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
        var string = AttributedString("DAY")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var weekTitle: AttributedString {
        var string = AttributedString("WEEK")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var monthTitle: AttributedString {
        var string = AttributedString("MONTH")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var yearTitle: AttributedString {
        var string = AttributedString("YEAR")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
}
