//
//  SubscriptionPlanViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 25/10/2023.
//

import Combine
import RevenueCat
import SwiftUI

protocol SubscriptionPlanViewModelProtocol where Self: ObservableObject {
    var selectedPackage: Package? { get set }
    var offering: Offering? { get set }
    var isSelectedPackageMonthly: Bool { get }
    
    func isMonthlySubscription(package: Package) -> Bool
}

final class SubscriptionPlanViewModel: SubscriptionPlanViewModelProtocol {
    @Published var selectedPackage: Package?
    @Published var offering: Offering?
    
    @ObservedObject private var userSubscriptionViewModel: UserSubscriptionViewModel
    
    var isSelectedPackageMonthly: Bool {
        if let subscriptionPeriod = selectedPackage?.storeProduct.subscriptionPeriod {
            return subscriptionPeriod.unit == .month
        }
        return false
    }
        
    init(userSubscriptionViewModel: UserSubscriptionViewModel) {
        self.userSubscriptionViewModel = userSubscriptionViewModel
        self.offering = userSubscriptionViewModel.offerings?.current
        self.selectedPackage = userSubscriptionViewModel.offerings?.current?.availablePackages.first(where: { $0.packageType == .annual })
    }
    
    func isMonthlySubscription(package: Package) -> Bool {
        if let subscriptionPeriod = package.storeProduct.subscriptionPeriod {
            return subscriptionPeriod.unit == .month
        }
        return false
    }
}

