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

public extension Resolver {
    static func registerDependencies() {
        register {
            AppRouter(with: NavigationPath())
        }.scope(.application)
        
        register {
            WorksDeletionViewModel()
        }.scope(.shared)
        
        register {
            HomeRouter(with: resolve())
        }.scope(.shared)
        
        register {
            HomeViewModel(router: resolve())
        }.scope(.shared)
        
        register {
            iCloudSettings()
        }.scope(.application)
        
        register {
            MoreViewModel()
        }.scope(.shared)
        
        register {
            NotificationManager()
        }.scope(.application)
        
        register {
            PersistanceManager()
        }.scope(.application)
        
        register {
            ProfileRouter(with: resolve())
        }.scope(.shared)
        
        register {
            ProfileViewModel(router: resolve())
        }.scope(.shared)
        
        register {
            ScheduleRouter(with: resolve())
        }.scope(.shared)
        
        register {
            ScheduleViewModel(router: resolve())
        }.scope(.shared)
        
        register {
            StatsViewModel()
        }.scope(.shared)
        
        register {
            StatsFilterViewModel()
        }.scope(.shared)
    }
}
