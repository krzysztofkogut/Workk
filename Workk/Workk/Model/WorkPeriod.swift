//
//  WorkPeriod.swift
//  Workk
//
//  Created by Krzysztof Kogut on 28/02/2024.
//

import SwiftUI

// Task Model and Sample Tasks...
// Array of Working Periods...
public struct WorkPeriod: Identifiable {
    public var id = UUID()
    var title: String
    var time: Date = .init()
}

// Total Working Period Meta View...
public struct WorkPeriodMetaData: Identifiable {
    public var id = UUID()
    var workPeriod: [WorkPeriod]
    var date: Date
}

// sample Date for Testing...
func getSampleDate(offset: Int) -> Date {
    let calender = Calendar.current

    let date = calender.date(byAdding: .day, value: offset, to: Date())

    return date ?? Date()
}

// Sample Data
var workSampleData: [WorkPeriodMetaData] = [
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "DAZN"),
                                    WorkPeriod(title: "Workk"),
                                    WorkPeriod(title: "Workk"),
                                    WorkPeriod(title: "Workk"),
                                    WorkPeriod(title: "Workk"),
                                    WorkPeriod(title: "Workk")],
                       date: getSampleDate(offset: 1)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "DAZN")],
                       date: getSampleDate(offset: -3)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "itCraft")],
                       date: getSampleDate(offset: -8)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "Revolut")],
                       date: getSampleDate(offset: 10)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "Revolut")],
                       date: getSampleDate(offset: -22)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "DAZN")],
                       date: getSampleDate(offset: 15)),
    WorkPeriodMetaData(workPeriod: [WorkPeriod(title: "Workk")],
                       date: getSampleDate(offset: -20)),
]
