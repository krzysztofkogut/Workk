//
//  Job+CoreDataProperties.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var hourlyRate: Float
    @NSManaged public var work: NSSet?

    public var workArray: [Work] {
        let set = work as? Set<Work> ?? []
        
        return set.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: Generated accessors for work
extension Job {

    @objc(addWorkObject:)
    @NSManaged public func addToWork(_ value: Work)

    @objc(removeWorkObject:)
    @NSManaged public func removeFromWork(_ value: Work)

    @objc(addWork:)
    @NSManaged public func addToWork(_ values: NSSet)

    @objc(removeWork:)
    @NSManaged public func removeFromWork(_ values: NSSet)

}

extension Job : Identifiable {

}
