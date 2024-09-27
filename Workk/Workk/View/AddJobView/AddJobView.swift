//
//  AddJobView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 10/06/2024.
//

import SwiftUI

struct AddJobView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isSaveButtonEnabled = true
    @State private var name: String = ""
    @State private var hourlyRate: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                        .font(.title)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Text("Add new job")
                .font(.latoBold(size: 28))
                .foregroundColor(.black)
                .padding(.bottom, 16)
            
            TextField("Job name", text: $name)
                .font(.latoRegular(size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.wildSand, in: .rect(cornerRadius: 16))
            
            TextField("Hourly rate", text: $hourlyRate)
                .keyboardType(.decimalPad)
                .font(.latoRegular(size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.wildSand, in: .rect(cornerRadius: 16))
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .safeAreaInset(edge: .bottom) {
            Button {
                addItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.white)
            }
            .disabled(!isSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSaveButtonEnabled ? .black : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
}

extension AddJobView {
    private func addItem() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        let newItem = Job(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        
        if let rate = formatter.number(from: hourlyRate) {
            newItem.hourlyRate = rate.floatValue
        } else {
            newItem.hourlyRate = 0.0
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    AddJobView()
}
