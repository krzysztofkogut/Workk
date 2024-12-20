//
//  Job+CoreDataProperties.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import CoreData
import Foundation

public extension Job {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged var name: String
    @NSManaged var id: UUID?
    @NSManaged var hourlyRate: Float
    @NSManaged var work: NSSet?

    var workArray: [Work] {
        let set = work as? Set<Work> ?? []

        return set.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: Generated accessors for work

public extension Job {
    @objc(addWorkObject:)
    @NSManaged func addToWork(_ value: Work)

    @objc(removeWorkObject:)
    @NSManaged func removeFromWork(_ value: Work)

    @objc(addWork:)
    @NSManaged func addToWork(_ values: NSSet)

    @objc(removeWork:)
    @NSManaged func removeFromWork(_ values: NSSet)
}

extension Job: Identifiable {}
