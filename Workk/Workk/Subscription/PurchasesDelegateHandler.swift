//
//  PurchasesDelegateHandler.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/01/2025.
//

import Foundation
import Resolver
import RevenueCat

class PurchasesDelegateHandler: NSObject, ObservableObject, PurchasesDelegate {
    
    let userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    /**
     Whenever the `shared` instance of Purchases updates the CustomerInfo cache, this method will be called.
    
     - Note: CustomerInfo is not pushed to each Purchases client, it has to be fetched.
     This delegate method is only called when the SDK updates its cache after an app launch, purchase, restore, or fetch.
     You still need to call `Purchases.shared.customerInfo` to fetch CustomerInfo regularly.
     */
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        
        /// - Update our published customerInfo object
        userSubscriptionViewModel.customerInfo = customerInfo
    }

    /**
     - Note: this can be tested by opening a link like:
     itms-services://?action=purchaseIntent&bundleId=<BUNDLE_ID>&productIdentifier=<SKPRODUCT_ID>
     */
    func purchases(_ purchases: Purchases,
                   readyForPromotedProduct product: StoreProduct,
                   purchase startPurchase: @escaping StartPurchaseBlock) {
        startPurchase { [weak self] (transaction, info, error, cancelled) in
            if let info = info, error == nil, !cancelled {
                self?.userSubscriptionViewModel.customerInfo = info
            }
        }
    }

}
