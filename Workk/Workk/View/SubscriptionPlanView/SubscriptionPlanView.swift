//
//  SubscriptionPlanView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 25/10/2023.
//

import SwiftUI

struct SubscriptionPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlanViewModel? = nil
    @State private var dayStartDate: Date = .now
    
    var selectedPlanString: String {
        guard let plan = selectedPlan?.price else {
            return "Continue"
        }
        
        return "Continue - \(String(format: "%.2f", plan))$"
    }
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("Workk premium")
        string.font = .latoBlack(size: 28)
        
        if let range = string.range(of: "Workk") {
            string[range].font = .nunitoBlack(size: 28)
        }
        
        return string
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
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
                
                Text(workkPremiumTitle)
                    .foregroundStyle(.black)
            }
            .padding(16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.black)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("Access to the stats view")
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.black)
                                
                                Text("Check and compare all you working hours and earned money")
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.black)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("iCloud sync")
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.black)
                                
                                Text("Synchronize your data between all your Apple devices by iCloud")
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.black)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("Export data")
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.black)
                                
                                Text("Export your data to .cvs, .xls and use it anywhere")
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.black)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("No more ads")
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.black)
                                
                                Text("Do not be disturbed by any ads")
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    
                    Text("50% off in the premiere month")
                        .foregroundStyle(.black)
                        .font(.nunitoBold(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.top, -8)
                    
                    ForEach(SubscriptionPlanViewModel.allCases, id: \.rawValue) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.latoBold(size: 18))
                                Text(item.description)
                                    .font(.latoRegular(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .frame(height: selectedPlan == item ? 90 : 80)
                        .background {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(selectedPlan == item ? .black : .clear, lineWidth: 2)
                        }
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                self.selectedPlan = item
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Button {
                        print("privacy")
                    } label: {
                        Text("Terms & Conditions")
                            .font(.nunitoBold(size: 16))
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .background {
            Color(.wildSand)
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    print("continue")
                } label: {
                    Text(selectedPlanString)
                        .font(.latoBold(size: 16))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                }
                .modifier(FilledButton())
                .background(selectedPlan == nil ? .gray : .black, in: .rect(cornerRadius: 24))
                .disabled(selectedPlan == nil)
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    SubscriptionPlanView()
}
