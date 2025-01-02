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
            return "continue_title".localized
        }
        
        return "continue_title".localized + " - \(String(format: "%.2f", plan))"
    }
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("workk_premium_title".localized)
        string.font = .latoBlack(size: 28)
        string.foregroundColor = .blackWhite
        
        if let range = string.range(of: "workk_title".localized) {
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
                            .foregroundColor(.blackWhite)
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
                                .fill(.blackWhite)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("stats_access_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("stats_access_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("icloud_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("icloud_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("export_data_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("export_data_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 250, alignment: .leading)
                        }
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text("ads_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("ads_description".localized)
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
                    
                    Text("promo_description".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.nunitoBold(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.top, -8)
                    
                    ForEach(SubscriptionPlanViewModel.allCases, id: \.rawValue) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.latoBold(size: 18))
                                    .foregroundStyle(.blackWhite)
                                Text(item.description)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .frame(height: selectedPlan == item ? 90 : 80)
                        .background {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.whiteTheme)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(selectedPlan == item ? .blackWhite : .clear, lineWidth: 2)
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
                        Text("terms_conditions_title".localized)
                            .font(.nunitoBold(size: 16))
                            .foregroundStyle(.blackWhite)
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
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                }
                .modifier(FilledButton())
                .background(selectedPlan == nil ? .gray : .blackWhite, in: .rect(cornerRadius: 24))
                .disabled(selectedPlan == nil)
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    SubscriptionPlanView()
}
