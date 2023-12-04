//
//  ModuleRoutable.swift
//  Workk
//
//  Created by Krzysztof Kogut on 13/11/2023.
//

import Foundation

public protocol ModuleRouter {
    var appRouter: AppRouter { get }
}

public enum ModuleExit: Hashable {
    case showCatch
    case showBackpack
}
