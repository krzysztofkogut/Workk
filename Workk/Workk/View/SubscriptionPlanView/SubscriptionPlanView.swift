//
//  SubscriptionPlanView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 25/10/2023.
//

import Resolver
import RevenueCat
import RevenueCatUI
import SwiftUI

struct SubscriptionPlanView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    @State private var dayStartDate: Date = .now
    @State private var showTermsAndConditions = false
    @State private var isPurchasing: Bool = false
    @State private var error: NSError?
    @State private var displayError: Bool = false
    
    @StateObject private var viewModel: SubscriptionPlanViewModel = Resolver.resolve()
    @StateObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    var selectedPlanString: String {
        guard let package = viewModel.selectedPackage else {
            return "continue_title".localized
        }
        
        if package.storeProduct.introductoryDiscount != nil {
            return "try_for_free_title".localized
        }
        
        return "continue_title".localized + " - " + package.localizedPriceString
    }
    
    var workkPremiumTitle: AttributedString {
        var string = AttributedString("workk_premium_title".localized)
        string.font = .latoBlack(size: 28)
        string.foregroundColor = .blueRibbon
        
        if let range = string.range(of: "workk_title".localized) {
            string[range].font = .nunitoBlack(size: 28)
            string[range].foregroundColor = .blackWhite
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
            }
            .padding(16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text("stats_access_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("stats_access_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .multilineTextAlignment(.leading)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text("icloud_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("icloud_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .multilineTextAlignment(.leading)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text("export_data_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("export_data_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .multilineTextAlignment(.leading)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text("ads_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("ads_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .multilineTextAlignment(.leading)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Circle()
                                .fill(.blackWhite)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text("unlimited_entries_title".localized)
                                    .font(.latoBold(size: 16))
                                    .foregroundStyle(.blackWhite)
                                
                                Text("unlimited_entries_description".localized)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 24)
                                        
                    HStack {
                        ForEach(viewModel.offering?.availablePackages ?? []) { package in
                            VStack(spacing: 0) {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundStyle(viewModel.selectedPackage == package ? .whiteTheme : .blackWhite)
                                    .opacity(viewModel.selectedPackage == package ? 1 : 0)
                                    .padding(.top, 8)
                                
                                Text(package.storeProduct.localizedTitle)
                                    .font(.latoBlack(size: 18))
                                    .foregroundStyle(viewModel.selectedPackage == package ? .whiteTheme : .blackWhite)
                                    .padding(.top, 8)
                                
                                Text((package.storeProduct.localizedPricePerMonth ?? "") + "/" + "month_title".localized.lowercased())
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(viewModel.selectedPackage == package ? .whiteTheme : .blackWhite)
                                    .padding(.top, 8)
                                
                                Text((package.storeProduct.localizedPricePerYear ?? "") + "/" + "year_title".localized.lowercased())
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(viewModel.selectedPackage == package ? .whiteTheme : .blackWhite)

                                Text("free_plan_description".localized)
                                    .font(.latoRegular(size: 12))
                                    .foregroundStyle(viewModel.selectedPackage == package ? .whiteTheme : .blackWhite)
                                    .padding(.top, 8)
                                    .opacity(package.storeProduct.introductoryDiscount == nil ? 0 : 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 32)
                            .frame(maxWidth: 250)
                            .background(viewModel.selectedPackage == package ? .blackWhite : .whiteTheme, in: .rect(cornerRadius: 16))
                            .onTapGesture {
                                viewModel.selectedPackage = package
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Button {
                        Task {
                            try? await Purchases.shared.restorePurchases()
                        }
                    } label: {
                        Text("Restore purchase")
                            .font(.nunitoBold(size: 16))
                            .foregroundStyle(.blackWhite)
                    }
                    .padding(.top, 8)
                    
                    Button {
                        showTermsAndConditions = true
                    } label: {
                        Text("terms_conditions_title".localized)
                            .font(.nunitoBold(size: 16))
                            .foregroundStyle(.blackWhite)
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 24)
                }
            }
            
            VStack(spacing: 4) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.blackWhite)
                    .frame(maxWidth: .infinity)
                
                Text(viewModel.selectedPackage?.storeProduct.localizedTitle ?? "")
                    .font(.latoBold(size: 16))
                    .foregroundStyle(.blackWhite)
                    .padding(.top, 2)

                HStack(spacing: 4) {
                    Text((viewModel.selectedPackage?.storeProduct.localizedPricePerYear ?? "") + "/" + "year_title".localized.lowercased())
                        .font(.latoBold(size: 14))
                        .hide(if: viewModel.isSelectedPackageMonthly)
                    
                    HStack(spacing: 0) {
                        Text("(")
                        Text((viewModel.selectedPackage?.storeProduct.localizedPricePerMonth ?? "") + "/" + "month_title".localized.lowercased())
                        Text(")")
                    }
                    .font(.latoBold(size: 14))
                    .hide(if: viewModel.isSelectedPackageMonthly)
                    
                    Text((viewModel.selectedPackage?.storeProduct.localizedPricePerMonth ?? "") + "/" + "month_title".localized.lowercased())
                        .font(.latoBold(size: 14))
                        .hide(if: !viewModel.isSelectedPackageMonthly)
                }
                .foregroundStyle(.blackWhite)
                
                Text("subscription_plan_cancel_anytime".localized)
                    .font(.latoBold(size: 14))
                    .foregroundStyle(.blackWhite)
                    .padding(.bottom, 8)
                
                Button {
                    guard let selectedPackage = viewModel.selectedPackage else {
                        return
                    }
                    
                    isPurchasing = true
                    
                    Task {
                        do {
                            let result = try await Purchases.shared.purchase(package: selectedPackage)

                            /// - Set 'isPurchasing' state to `false`
                            self.isPurchasing = false

                            if !result.userCancelled {
                                dismiss()
                            }
                        } catch {
                            self.isPurchasing = false
                            self.error = error as NSError
                            self.displayError = true
                        }
                    }
                } label: {
                    Text(selectedPlanString)
                        .font(.latoBlack(size: 16))
                        .foregroundStyle(.whiteBlack)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(viewModel.selectedPackage == nil ? .gray : .blackWhite, in: .rect(cornerRadius: 24))
                        .disabled(viewModel.selectedPackage == nil)
                }
                .hide(if: userSubscriptionViewModel.subscriptionActive)
            }
        }
        .background {
            Color(.wildSand)
                .ignoresSafeArea()
        }
        .onDisappear {
            YourProfileTip.hasSeenOnboarding = hasSeenOnboarding
            DropdownPickerHomeTip.hasSeenOnboarding = hasSeenOnboarding
            PeriodFilterHomeTip.hasSeenOnboarding = hasSeenOnboarding
        }
        .overlay {
            ZStack {
                Color.wildSand.opacity(0.9)
                    .blur(radius: 0, opaque: false)
                
                ProgressView {
                    Text("Loading")
                        .font(.latoRegular(size: 16))
                        .foregroundStyle(.gray)
                }
            }
            .ignoresSafeArea()
            .hide(if: !isPurchasing)
        }
        .sheet(isPresented: $showTermsAndConditions) {
            WebViewWithCloseButton(url: Constants.termsAndConditionsURL,
                                   navigationTitle: "terms_conditions_title".localized)
        }
        .alert(
            isPresented: $displayError,
            error: error,
            actions: { _ in
                Button(role: .cancel,
                       action: { self.displayError = false },
                       label: { Text("ok_title".localized) })
            },
            message: { Text($0.recoverySuggestion ?? "Please try again") }
        )
    }
}

#Preview {
    SubscriptionPlanView()
}
