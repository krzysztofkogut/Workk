//
//  WorkScheduler.swift
//  Workk
//
//  Created by Krzysztof Kogut on 13/02/2025.
//

import SwiftUI
import CoreData

struct WorkSchedulerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var startHour = Date()
    @State private var endHour = Date()
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedDays: Set<Int> = []
    
    let weekdays = [(1, "Monday"), (2, "Tuesday"), (3, "Wednesday"), (4, "Thursday"), (5, "Friday"), (6, "Saturday"), (7, "Sunday")]
    
    var body: some View {
        Form {
            Section(header: Text("Select Hours")) {
                DatePicker("Start Hour", selection: $startHour, displayedComponents: .hourAndMinute)
                DatePicker("End Hour", selection: $endHour, displayedComponents: .hourAndMinute)
            }
            
            Section(header: Text("Select Date Range")) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
            
            Section(header: Text("Select Days")) {
                ForEach(weekdays, id: \.0) { day in
                    Button(action: {
                        toggleDaySelection(day.0)
                    }) {
                        HStack {
                            Text(day.1)
                            Spacer()
                            if selectedDays.contains(day.0) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Button("Generate Work Entries") {
                generateWorkEntries()
            }
        }
        .navigationTitle("Work Scheduler")
    }
    
    private func toggleDaySelection(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func generateWorkEntries() {
        let calendar = Calendar.current
        var date = startDate
        
        while date <= endDate {
            let components = calendar.dateComponents([.weekday], from: date)
            if let weekday = components.weekday, selectedDays.contains(weekday) {
                let work = Work(context: viewContext)
                work.id = UUID()
                work.startDate = combineDateWithTime(date: date, time: startHour)
                work.endDate = combineDateWithTime(date: date, time: endHour)
                work.hoursWorked = Float(calendar.dateComponents([.hour], from: work.startDate, to: work.endDate).hour ?? 0)
                
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save work entity: \(error)")
                }
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
    }
    
    private func combineDateWithTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)) ?? date
    }
}
