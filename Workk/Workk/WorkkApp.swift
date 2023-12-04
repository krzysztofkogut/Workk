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
//    @ObservedObject var router: AppRouter = Resolver.resolve()
    
    var body: some Scene {
        WindowGroup {
//            NavigationStack(path: $router.path) {
                MainTabView()
//                    .withHomeRoutes()
//            }
        }
    }
}
