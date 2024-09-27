//
//  BannerAd.swift
//  Workk
//
//  Created by Krzysztof Kogut on 20/02/2024.
//

import GoogleMobileAds
import SwiftUI

struct BannerAd: UIViewRepresentable {
    @Binding var isLoaded: Bool
    var unitID: String
    
    func makeCoordinator() -> Coordinator {
        // For Implementing Delegates...
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let adView = GADBannerView(adSize: GADAdSizeBanner)
        
        adView.adUnitID = unitID
        adView.rootViewController = UIApplication.shared.getRootViewController()
        adView.delegate = context.coordinator
        adView.load(GADRequest())
        
        return adView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        var parent: BannerAd
        
        init(parent: BannerAd) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("bannerViewDidReceiveAd")
            withAnimation(.interactiveSpring(duration: 0.8)) {
                parent.isLoaded = true
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
            withAnimation(.interactiveSpring(duration: 0.8)) {
                parent.isLoaded = false
            }
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            print("bannerViewDidRecordImpression")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("bannerViewWillPresentScreen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            print("bannerViewWillDIsmissScreen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            print("bannerViewDidDismissScreen")
        }
    }
}
