//
//  Work+CoreDataClass.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import Foundation
import CoreData

@objc(Work)
public class Work: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
    }
}
