//
//  YearDatePicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 06/09/2024.
//

import SwiftUI

struct YearDatePicker: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let rangeOfYears = Array(1900 ... Calendar.current.component(.year, from: Date()))

    var body: some View {
        VStack {
            Text("Selected Year: \(selectedYear)")
                .padding()

            Picker("Select Year", selection: $selectedYear) {
                ForEach(rangeOfYears, id: \.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .labelsHidden()
            .padding()

            // Done Button
            Button("Done") {
                // Handle Done action, if needed
                print("Selected Year: \(selectedYear)")
            }
            .padding()
        }
    }
}

struct YearDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        YearDatePicker()
    }
}
