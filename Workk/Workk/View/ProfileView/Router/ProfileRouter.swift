//
//  ProfileRouter.swift
//  Workk
//
//  Created by Krzysztof Kogut on 01/12/2024.
//

import SwiftUI

protocol ProfileRouterProtocol {
    func pop()
    func showJobListView()
}

enum ProfileRoute: Hashable {
    case jobListView
}

class ProfileRouter: ModuleRouter, ProfileRouterProtocol {
    var appRouter: AppRouter

    init(with appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    private func navigate(to target: ProfileRoute) {
        appRouter.navigate(to: target)
    }

    func pop() {
        appRouter.pop()
    }

    func showJobListView() {
        navigate(to: .jobListView)
    }
}
