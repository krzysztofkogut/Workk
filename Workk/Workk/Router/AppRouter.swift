//
//  AppRouter.swift
//  Workk
//
//  Created by Krzysztof Kogut on 13/11/2023.
//

import SwiftUI

public class AppRouter: ObservableObject {
    @Published public var path: NavigationPath

    public init(with path: NavigationPath) {
        self.path = path
    }

    public func navigate(to destination: any Hashable) {
        path.append(destination)
    }

    public func pop() {
        path.removeLast()
    }
}
