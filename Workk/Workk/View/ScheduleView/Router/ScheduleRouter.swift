//
//  ScheduleRouter.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/03/2024.
//

import SwiftUI

protocol ScheduleRouterProtocol {
    func pop()
    func showAddWorkTimeView(selectedWork: Binding<Work?>,
                             selectedFilter: Binding<PeriodFilter>,
                             selectedWorkName: Binding<String?>)
}

enum ScheduleRoute: Hashable {
    case addWorkTimeView(selectedWork: Binding<Work?>, selectedFilter: Binding<PeriodFilter>, selectedWorkName: Binding<String?>)

    static func == (lhs: ScheduleRoute, rhs: ScheduleRoute) -> Bool {
        switch (lhs, rhs) {
        case (.addWorkTimeView(let lhsWork, let lhsFilter, let lhsWorkName), .addWorkTimeView(let rhsWork, let rhsFilter, let rhsWorkName)):
            return lhsFilter.wrappedValue == rhsFilter.wrappedValue
                && lhsWorkName.wrappedValue == rhsWorkName.wrappedValue
                && lhsWork.wrappedValue == rhsWork.wrappedValue
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .addWorkTimeView(let selectedWork, let selectedFilter, let selectedWorkName):
            hasher.combine(selectedFilter.wrappedValue)
        }
    }
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

    func showAddWorkTimeView(selectedWork: Binding<Work?>,
                             selectedFilter: Binding<PeriodFilter>,
                             selectedWorkName: Binding<String?>)
    {
        navigate(to: .addWorkTimeView(selectedWork: selectedWork,
                                      selectedFilter: selectedFilter,
                                      selectedWorkName: selectedWorkName))
    }
}
