//
//  HomeRouter.swift
//  Workk
//
//  Created by Krzysztof Kogut on 13/11/2023.
//

import SwiftUI

protocol HomeRouterProtocol {
    func pop()
    func showSubscriptionPlanView()
}

enum HomeRoute: Hashable {
    case subscriptionPlanView
}

class HomeRouter: ModuleRouter, HomeRouterProtocol {
    var appRouter: AppRouter
    
    init(with appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    private func navigate(to target: HomeRoute) {
        appRouter.navigate(to: target)
    }

    func pop() {
        appRouter.pop()
    }
    
    func showSubscriptionPlanView() {
        navigate(to: .subscriptionPlanView)
    }
}
