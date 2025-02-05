//
//  WorksDeletionView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 09/11/2024.
//

import Resolver
import SwiftUI

struct WorksDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("currencyIdentifier") private var currencyIdentifier: String = Locale.current.currency?.identifier ?? "USD"
    
    @ObservedObject private var viewModel: WorksDeletionViewModel = Resolver.resolve()
    
    @Binding var selectedWorks: Set<Work>
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("select_delete_title".localized)
                    .font(.latoBold(size: 18))
                    .foregroundColor(.blackWhite)
                
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
            }
            .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    Text(viewModel.dayTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .hide(if: selectedWorks.filter { $0.periodType == "day" }.isEmpty)
                    
                    VStack(spacing: 4) {
                        ForEach(selectedWorks.filter { $0.periodType == "day" }) { work in
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(alignment: .center, spacing: 2) {
                                        Text(work.job?.name ?? "Unknown Job")
                                            .font(.latoBold(size: 18))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.trailing, 4)

                                        Text("project_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true || work.task?.isEmpty ?? true)

                                        Text("task_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.task?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: (work.project?.isEmpty ?? true || work.note?.isEmpty ?? true) && (work.task?.isEmpty ?? true || work.note?.isEmpty ?? true))

                                        Text("note_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.note?.isEmpty ?? true)
                                    }

                                    Text(work.startDate.currentHourString + " - " + work.endDate.currentHourString + ", \(work.startDate.currentShortDateString)")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.blackWhite)

                                    Text("overtime_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.top, 1)
                                        .hide(if: !work.isOvertime)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                        .font(.latoBold(size: 16))
                                        .foregroundStyle(.blackWhite)
                                    
                                    Text(work.hoursWorkedTimeDifference + " | " + work.hourlyRate.formatFloatToString() +
                                        " \(currencyIdentifier.uppercased())" + "/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)

                                    Text(work.isPaid ? "paid_title".localized : "unpaid_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.blackWhite)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                            }
                            .background(.whiteTheme)
                            .cornerRadius(12)
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if selectedWorks.contains(where: { $0.id == work.id }) {
                                        selectedWorks.remove(work)
                                    } else {
                                        selectedWorks.insert(work)
                                    }
                                }
                                
                                if selectedWorks.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    Text(viewModel.weekTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .hide(if: selectedWorks.filter { $0.periodType == "week" }.isEmpty)
                    
                    VStack(spacing: 4) {
                        ForEach(selectedWorks.filter { $0.periodType == "week" }) { work in
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(alignment: .center, spacing: 2) {
                                        Text(work.job?.name ?? "Unknown Job")
                                            .font(.latoBold(size: 18))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.trailing, 4)

                                        Text("project_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true || work.task?.isEmpty ?? true)

                                        Text("task_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.task?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: (work.project?.isEmpty ?? true || work.note?.isEmpty ?? true) && (work.task?.isEmpty ?? true || work.note?.isEmpty ?? true))

                                        Text("note_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.note?.isEmpty ?? true)
                                    }

                                    Text(work.startDate.currentWeekScheduleString + ", \(work.startDate.currentYearString)")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.blackWhite)

                                    Text("overtime_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.top, 1)
                                        .hide(if: !work.isOvertime)
                                }
                                .padding(.horizontal, 16)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                        .font(.latoBold(size: 16))
                                        .foregroundColor(.blackWhite)
                                    
                                    Text(work.hoursWorkedString + " | " +
                                        work.moneyEarnedHourRate.formatFloatToString() +
                                        " \(currencyIdentifier.uppercased())" + "/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundStyle(.gray)
                                        .padding(.bottom, 2)

                                    Text(work.isPaid ? "paid_title".localized : "unpaid_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.blackWhite)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                            }
                            .background(.whiteTheme)
                            .cornerRadius(12)
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if selectedWorks.contains(where: { $0.id == work.id }) {
                                        selectedWorks.remove(work)
                                    } else {
                                        selectedWorks.insert(work)
                                    }
                                }
                                
                                if selectedWorks.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    Text(viewModel.monthTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .hide(if: selectedWorks.filter { $0.periodType == "month" }.isEmpty)
                    
                    VStack(spacing: 4) {
                        ForEach(selectedWorks.filter { $0.periodType == "month" }) { work in
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(alignment: .center, spacing: 2) {
                                        Text(work.job?.name ?? "Unknown Job")
                                            .font(.latoBold(size: 18))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.trailing, 4)

                                        Text("project_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true || work.task?.isEmpty ?? true)

                                        Text("task_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.task?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: (work.project?.isEmpty ?? true || work.note?.isEmpty ?? true) && (work.task?.isEmpty ?? true || work.note?.isEmpty ?? true))

                                        Text("note_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.note?.isEmpty ?? true)
                                    }

                                    Text(work.startDate.currentMonthString +  ", \(work.startDate.currentYearString)")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.blackWhite)

                                    Text("overtime_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.top, 1)
                                        .hide(if: !work.isOvertime)
                                }
                                .padding(.horizontal, 16)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                        .font(.latoBold(size: 16))
                                        .foregroundColor(.blackWhite)
                                    
                                    Text(work.hoursWorkedString + " | " +
                                        work.moneyEarnedHourRate.formatFloatToString() +
                                        " \(currencyIdentifier.uppercased())" + "/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)

                                    Text(work.isPaid ? "paid_title".localized : "unpaid_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.blackWhite)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                            }
                            .background(.whiteTheme)
                            .cornerRadius(12)
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if selectedWorks.contains(where: { $0.id == work.id }) {
                                        selectedWorks.remove(work)
                                    } else {
                                        selectedWorks.insert(work)
                                    }
                                }
                                
                                if selectedWorks.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    Text(viewModel.yearTitle)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 4)
                        .hide(if: selectedWorks.filter { $0.periodType == "year" }.isEmpty)
                    
                    VStack(spacing: 4) {
                        ForEach(selectedWorks.filter { $0.periodType == "year" }) { work in
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(alignment: .center, spacing: 2) {
                                        Text(work.job?.name ?? "Unknown Job")
                                            .font(.latoBold(size: 18))
                                            .foregroundStyle(.blackWhite)
                                            .padding(.trailing, 4)

                                        Text("project_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.project?.isEmpty ?? true || work.task?.isEmpty ?? true)

                                        Text("task_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.task?.isEmpty ?? true)

                                        Text("|")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: (work.project?.isEmpty ?? true || work.note?.isEmpty ?? true) && (work.task?.isEmpty ?? true || work.note?.isEmpty ?? true))

                                        Text("note_title".localized.first.map { String($0) } ?? "")
                                            .font(.latoBold(size: 12))
                                            .foregroundColor(.gray)
                                            .hide(if: work.note?.isEmpty ?? true)
                                    }

                                    Text(work.startDate.currentYearString)
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.blackWhite)

                                    Text("overtime_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                        .padding(.top, 1)
                                        .hide(if: !work.isOvertime)
                                }
                                .padding(.horizontal, 16)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(work.moneyEarned.formatFloatToString() + " " + currencyIdentifier.uppercased())
                                        .font(.latoBold(size: 16))
                                        .foregroundColor(.blackWhite)
                                    
                                    Text(work.hoursWorkedString + " | " +
                                        work.moneyEarnedHourRate.formatFloatToString() +
                                        " \(currencyIdentifier.uppercased())" + "/h")
                                        .font(.latoRegular(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)

                                    Text(work.isPaid ? "paid_title".localized : "unpaid_title".localized)
                                        .font(.latoBold(size: 14))
                                        .foregroundStyle(.blackWhite)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.blackWhite)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 16)
                            }
                            .background(.whiteTheme)
                            .cornerRadius(12)
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    if selectedWorks.contains(where: { $0.id == work.id }) {
                                        selectedWorks.remove(work)
                                    } else {
                                        selectedWorks.insert(work)
                                    }
                                }
                                
                                if selectedWorks.isEmpty {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    deleteSelectedWorks()
                    dismiss()
                } label: {
                    Text("delete_title".localized)
                        .font(.latoBold(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blackWhite, in: .rect(cornerRadius: 18))
                }
                
                Text("\(selectedWorks.count)")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.whiteBlack)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.blackWhite, in: .rect(cornerRadius: 18))
            }
            .padding(.bottom, 30)
        }
    }
    
    private func deleteSelectedWorks() {
        withAnimation {
            for item in selectedWorks {
                viewContext.delete(item)
            }
            selectedWorks.removeAll()
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
}
