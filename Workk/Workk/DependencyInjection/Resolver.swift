//
//  Resolver.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/10/2023.
//

import Resolver
import SwiftUI

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        
        registerDependencies()
        
        // Register view models.
        // Register domain managers.
        // Register network managers.
        // Register perisitence managers.
    }
}

extension Resolver {

    public static func registerDependencies() {        
        register {
            AppRouter(with: NavigationPath())
        }.scope(.application)
        
        register {
            HomeRouter(with: resolve())
        }.scope(.unique)
        
        register {
            HomeViewModel(router: resolve())
        }.scope(.unique)
        
        register {
            ScheduleRouter(with: resolve())
        }.scope(.unique)
        
        register {
            ScheduleViewModel(router: resolve())
        }.scope(.unique)
    }
}

