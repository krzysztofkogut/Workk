//
//  NSError+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/01/2025.
//

import Foundation

extension NSError: LocalizedError {

    public var errorDescription: String? {
        return self.localizedDescription
    }

}
