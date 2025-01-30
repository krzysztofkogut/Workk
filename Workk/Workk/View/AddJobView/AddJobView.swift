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
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @Binding var selectedJob: Job?
    
    @State private var isSaveButtonEnabled = false
    @State private var name: String = ""
    @State private var hourlyRate: String = ""
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)]
    ) private var works: FetchedResults<Work>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blackWhite)
                        .font(.title)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Text(selectedJob == nil ? "add_new_job_title".localized : "update_job_title".localized)
                .font(.latoBlack(size: 28))
                .foregroundColor(.blackWhite)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
            
            TextField("job_name_title".localized, text: $name)
                .foregroundStyle(.blackWhite)
                .font(.latoRegular(size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.whiteTheme, in: .rect(cornerRadius: 12))
            
            HStack(spacing: 0) {
                TextField("hourly_rate_title".localized, text: $hourlyRate)
                    .foregroundStyle(.blackWhite)
                    .keyboardType(.decimalPad)
                    .font(.latoRegular(size: 18))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                
                Spacer()
                
                Text(currencyIdentifier.uppercased())
                    .foregroundStyle(.blackWhite)
                    .font(.latoBold(size: 16))
                    .padding(.trailing, 16)
            }
            .background(.whiteTheme, in: .rect(cornerRadius: 12))
            
            Text("updating_hourly_rate_description".localized)
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
                       value.predictedEndTranslation.height > velocityThreshold
                    {
                        UIApplication.shared.dismissKeyboard()
                    }
                }
        )
        .onAppear {
            setupView()
        }
        .onChange(of: name) { _ in updateSaveButtonState() }
        .onChange(of: hourlyRate) { newValue in
            hourlyRate = newValue.formatNumberInput()
            updateSaveButtonState()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button {
                    selectedJob == nil ? addItem() : updateItem()
                    dismiss()
                } label: {
                    Text("save_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(isSaveButtonEnabled ? .blackWhite : .gray, in: .rect(cornerRadius: 18))
                }
                .disabled(!isSaveButtonEnabled)
            
                Text("add_job_conditions_decription".localized)
                    .font(.nunitoSemiBold(size: 12))
                    .foregroundStyle(.whiteBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray, in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 16)
                    .hide(if: isSaveButtonEnabled)
            }
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
    
    private func updateSaveButtonState() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isSaveButtonEnabled = (!name.isEmpty && !hourlyRate.isEmpty)
        }
        
        guard let job = selectedJob else {
            return
        }
        
        isSaveButtonEnabled = false
        
        var hasChanged = false
        
        hasChanged = name != job.name ||
            hourlyRate != job.hourlyRate.formatFloatToString()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isSaveButtonEnabled = (!name.isEmpty && !hourlyRate.isEmpty) && hasChanged
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
    
    private func updateItem() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        guard let job = selectedJob else {
            return
        }
        
        let worksForJob = works.filter { $0.jobName == job.name }
        
        for work in worksForJob {
            work.job = job
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
