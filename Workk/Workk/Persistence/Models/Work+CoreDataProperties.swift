//
//  Work+CoreDataProperties.swift
//  Workk
//
//  Created by Krzysztof Kogut on 29/05/2024.
//
//

import CoreData
import Foundation

public extension Work {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Work> {
        return NSFetchRequest<Work>(entityName: "Work")
    }

    @NSManaged var id: UUID?
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date
    @NSManaged var hourlyRate: Float
    @NSManaged var task: String?
    @NSManaged var project: String?
    @NSManaged var note: String?
    @NSManaged var moneyEarned: Float
    @NSManaged var periodType: String?
    @NSManaged var isPaid: Bool
    @NSManaged var job: Job?
}

extension Work: Identifiable {}

public extension Work {
    var hoursWorked: Float {
        startDate.timeDifferenceInHours(to: endDate)
    }

    var hoursWorkedString: String {
        startDate.timeDifference(to: endDate)
    }

    var hourRateMoneyEarned: Float {
        hourlyRate * hoursWorked
    }

    var moneyEarnedHourRate: Float {
        moneyEarned / hoursWorked
    }

    var jobName: String {
        job?.name ?? "n/a"
    }
}
