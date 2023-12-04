//
//  MoreViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import Foundation

enum MoreViewModel: Int, CaseIterable {
    case settings
    case export
    case contact
    case logout
    case help
    case recommend
    case review
    
    var description: String {
        switch self {
        case .settings:
            return "Settings"
        case .export:
            return "Export data"
        case .contact:
            return "Contact us"
        case .logout:
            return "Logout"
        case .help:
            return "Help"
        case .recommend:
            return "Recommend the app"
        case .review:
            return "Review the app on the App Store"
        }
    }
    
    var imageName: String {
        switch self {
        case .settings:
            return "gearshape"
        case .export:
            return "arrow.up.doc"
        case .contact:
            return "message.circle"
        case .logout:
            return "arrow.left.square"
        case .help:
            return "questionmark.app"
        case .recommend:
            return "heart"
        case .review:
            return "star.square"
        }
    }
}
