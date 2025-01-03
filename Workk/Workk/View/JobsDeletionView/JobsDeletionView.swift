//
//  JobsDeletionView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/11/2024.
//

import Resolver
import SwiftUI

struct JobsDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Job.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)]
    ) private var jobs: FetchedResults<Job>
    
    @State var selectedJob: Job? = nil
    @State private var selectedJobs: Set<Job> = []
    @State private var showAddJobView = false
    @State private var showSubscriptionPlanView = false
    @State private var deleteMode = false
    
    var jobsTitle: AttributedString {
        var string = AttributedString("jobs_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var deleteTitle: AttributedString {
        var string = AttributedString("delete_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var cancelTitle: AttributedString {
        var string = AttributedString("cancel_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("edit_jobs_title".localized)
                    .font(.latoBold(size: 18))
                    .foregroundColor(.blackWhite)

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .foregroundColor(.blackWhite)
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    Button {
                        if deleteMode {
                            selectedJobs = []
                        }
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            deleteMode.toggle()
                        }
                    } label: {
                        Text(deleteMode ? cancelTitle : deleteTitle)
                            .font(.latoBlack(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                Text(jobsTitle)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .hide(if: jobs.isEmpty)
                
                VStack(spacing: 4) {
                    ForEach(jobs) { job in
                        HStack(spacing: 0) {
                            Text(job.name)
                                .font(.latoRegular(size: 18))
                            
                            Spacer()
                            
                            Image(systemName: selectedJobs.contains(where: { $0.id == job.id }) ?
                                  "checkmark.circle.fill" : "circle")
                                .resizable()
                                .foregroundStyle(.blackWhite)
                                .frame(width: 20, height: 20)
                                .hide(if: !deleteMode)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(.whiteTheme)
                        .cornerRadius(12)
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.4)) {
                                if deleteMode {
                                    if selectedJobs.contains(where: { $0.id == job.id }) {
                                        selectedJobs.remove(job)
                                    } else {
                                        selectedJobs.insert(job)
                                    }
                                } else {
                                    showAddJobView(job: job)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .padding(.horizontal, 16)
        .background {
            Color(.wildSand)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showAddJobView) {
            AddJobView(selectedJob: $selectedJob)
        }
        .fullScreenCover(isPresented: $showSubscriptionPlanView) {
            SubscriptionPlanView()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    if deleteMode {
                        deleteSelectedJobs()
                        deleteMode = false
                    } else {
                        jobs.count < 3 ? showAddJobView() : showSubscriptionPlanView.toggle()
                    }
                } label: {
                    Text(deleteMode ? "delete_title".localized : "add_new_job_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.blackWhite, in: .rect(cornerRadius: 18))
                    
                Text("\(selectedJobs.count)")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.blackWhite, in: .rect(cornerRadius: 18))
                    .hide(if: !deleteMode)
            }
            .padding(.bottom, 30)
        }
    }
    
    private func deleteSelectedJobs() {
        withAnimation {
            for item in selectedJobs {
                viewContext.delete(item)
            }
            selectedJobs.removeAll()
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func showAddJobView(job: Job? = nil) {
        selectedJob = job
        showAddJobView = true
    }
}
