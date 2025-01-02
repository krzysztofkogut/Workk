//
//  MailOption.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/11/2024.
//

import SwiftUI
import Foundation

enum MailOption: String {
    case contactUs
    case reportBug
    case reportWrongTranslation
    case suggestNewFunc

    var mailTitle: String {
        switch self {
        case .contactUs:
            "Contact Workk"
        case .reportBug:
            "Bug report in Workk"
        case .reportWrongTranslation:
            "Translation bug in Workk"
        case .suggestNewFunc:
            "New cool func in Workk"
        }
    }

    var mailBody: String {
        switch self {
        case .contactUs:
            """
            Hi,

            I want to tell you...
            """
        case .reportBug:
            """
            Hi,

            there is a bug in the app.
            Details:
            Where in the app:
            What is the wrong behavior:

            Screenshoot/video in the attachment

            (Thank you for your help! - Workk team)

            version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            iOS: \(UIDevice.current.systemVersion)
            """
        case .reportWrongTranslation:
            """
            Hi,

            there is a translation bug in the app.
            Details:
            Where in the app:
            What is the wrong translation:
            What translation should be:

            Screenshoot in the attachment

            (Thank you for your help! - Workk team)

            version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            iOS: \(UIDevice.current.systemVersion)
            """
        case .suggestNewFunc:
            """
            Hi,

            it would be great to have this feature in Workk...
            """
        }
    }
}
