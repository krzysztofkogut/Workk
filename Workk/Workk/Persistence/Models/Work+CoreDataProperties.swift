//
//  Work+CoreDataProperties.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import Foundation
import CoreData


extension Work {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Work> {
        return NSFetchRequest<Work>(entityName: "Work")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var hourlyRate: Float
    @NSManaged public var task: String?
    @NSManaged public var project: String?
    @NSManaged public var note: String?
    @NSManaged public var moneyEarned: Float
    @NSManaged public var periodType: String?
    @NSManaged public var isPaid: Bool
    @NSManaged public var job: Job?

}

extension Work : Identifiable {}

extension Work {
    public var hoursWorked: Float {
        startDate.timeDifferenceInHours(to: endDate)
    }
    
    public var hoursWorkedString: String {
        startDate.timeDifference(to: endDate)
    }
    
    public var hourRateMoneyEarned: Float {
        hourlyRate * hoursWorked
    }
    
    public var moneyEarnedHourRate: Float {
        moneyEarned / hoursWorked
    }
    
    public var jobName: String {
        job?.name ?? "n/a"
    }
}
