//
//  ScheduleRouter.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/03/2024.
//

import SwiftUI

protocol ScheduleRouterProtocol {
    func pop()
    func showAddNewEntryView()
}

enum ScheduleRoute: Hashable {
    case addNewEntryView
}

class ScheduleRouter: ModuleRouter, ScheduleRouterProtocol {
    var appRouter: AppRouter
    
    init(with appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    private func navigate(to target: ScheduleRoute) {
        appRouter.navigate(to: target)
    }

    func pop() {
        appRouter.pop()
    }
    
    func showAddNewEntryView() {
        navigate(to: .addNewEntryView)
    }
}
