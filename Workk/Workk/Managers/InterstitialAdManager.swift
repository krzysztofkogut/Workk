//
//  InterstitialAdManager.swift
//  Workk
//
//  Created by Krzysztof Kogut on 07/01/2025.
//

import GoogleMobileAds

class InterstitialAdManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    private var interstitialAd: GADInterstitialAd?
    private let adUnitID = "REDACTED_SERVICE_CONFIGURATION" //"REDACTED_SERVICE_CONFIGURATION"

    func loadAd() async {
        do {
            interstitialAd = try await GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }

    func showAd(from rootViewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            if let ad = self?.interstitialAd {
                ad.present(fromRootViewController: rootViewController)
            } else {
                print("Ad wasn't ready")
            }
        }
    }

    // MARK: - GADFullScreenContentDelegate Methods

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }

    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        interstitialAd = nil
        
        Task {
            await loadAd()
        }
    }
}
