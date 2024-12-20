//
//  ProfileRouterViewModifier.swift
//  Workk
//
//  Created by Krzysztof Kogut on 01/12/2024.
//

import SwiftUI

public extension View {
    func withProfileRoutes() -> some View {
        self.navigationDestination(for: ProfileRoute.self) { destination in
            switch destination {
            case .jobListView:
                JobsDeletionView()
            }
        }
    }
}
