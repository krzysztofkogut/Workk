//
//  ScheduleRouterViewModifier.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/03/2024.
//

import SwiftUI

public extension View {
    func withScheduleRoutes() -> some View {
        self.navigationDestination(for: ScheduleRoute.self) { destination in
            switch destination {
            case .addNewEntryView:
                SubscriptionPlanView()
            }
        }
    }
}
