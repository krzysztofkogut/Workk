//
//  Job+CoreDataClass.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import Foundation
import CoreData

@objc(Job)
public class Job: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
    }
}
