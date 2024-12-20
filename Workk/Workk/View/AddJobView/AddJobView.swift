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
    
    @Binding var selectedJob: Job?
    
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
                        .foregroundColor(.blackTheme)
                        .font(.title)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Text(selectedJob == nil ? "Add new job" : "Update job")
                .font(.latoBlack(size: 28))
                .foregroundColor(.blackTheme)
                .padding(.bottom, 32)
            
            TextField("Job name", text: $name)
                .font(.latoRegular(size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
            
            HStack(spacing: 0) {
                TextField("Hourly rate", text: $hourlyRate)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 18))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                
                Spacer()
                
                Text("PLN")
                    .font(.latoBold(size: 16))
                    .padding(.trailing, 16)
            }
            .background(.whiteTheme, in: .rect(cornerRadius: 12))
            
            Text("Updating hourly rate will not change previous entries for this job")
                .font(.nunitoSemiBold(size: 12))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .hide(if: selectedJob == nil)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(
            Color.wildSand
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    let threshold: CGFloat = 20
                    let velocityThreshold: CGFloat = 30
                            
                    if value.translation.height > threshold,
                       value.predictedEndTranslation.height > velocityThreshold {
                        UIApplication.shared.dismissKeyboard()
                    }
                }
        )
        .onAppear {
            setupView()
        }
        .onChange(of: hourlyRate) { newValue in
            hourlyRate = newValue.formatNumberInput()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                selectedJob == nil ? addItem() : updateItem()
                dismiss()
            } label: {
                Text("Save")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
            }
            .disabled(!isSaveButtonEnabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSaveButtonEnabled ? .blackTheme : .gray, in: .rect(cornerRadius: 18))
            .padding(.bottom, 16)
        }
    }
}

extension AddJobView {
    private func setupView() {
        guard let job = selectedJob else {
            return
        }
        
        name = job.name
        hourlyRate = job.hourlyRate.formatFloatToString()
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
    
    private func updateItem() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        guard let job = selectedJob else {
            return
        }
        
        job.name = name
        
        if let rate = formatter.number(from: hourlyRate) {
            job.hourlyRate = rate.floatValue
        } else {
            job.hourlyRate = 0.0
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

