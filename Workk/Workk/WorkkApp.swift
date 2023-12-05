//
//  WorkkApp.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import Resolver
import SwiftUI

@main
struct WorkkApp: App {
    
    var body: some Scene {
        WindowGroup {
                MainTabView()
                    .environment(\.locale, .init(identifier: "pl"))
        }
    }
}
