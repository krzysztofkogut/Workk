//
//  HomeRouterViewModifier.swift
//  Workk
//
//  Created by Krzysztof Kogut on 13/11/2023.
//

import SwiftUI

public extension View {
    func withHomeRoutes() -> some View {
        self.navigationDestination(for: HomeRoute.self) { destination in
            switch destination {
            case .subscriptionPlan:
                SubscriptionPlanView()
            }
        }
    }
}
