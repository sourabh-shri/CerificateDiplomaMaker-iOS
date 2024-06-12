//
//  GoogleAdClass.swift
//  CerificatesTemplates
//
//  Created by SMT Sourabh  on 07/06/24.
//  Copyright © 2024 Mobiona. All rights reserved.
//

import Foundation
import GoogleMobileAds

final class GoogleAdClass: NSObject, GADBannerViewDelegate, GADFullScreenContentDelegate {
    static let shared = GoogleAdClass()
    var interstitial: GADInterstitialAd?
    func addGoogleAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3293843557873754/1083311838", request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                // Optionally, you could retry loading the ad here
                return
            }
            if let ad = ad {
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
                print("Interstitial ad loaded successfully.")
            } else {
                print("Interstitial ad load returned nil.")
            }
        }
    }
    
    
    func showAd(controller: UINavigationController) {
        if interstitial != nil {
            interstitial!.present(fromRootViewController: controller)
        } else {
            print("Ad wasn't ready")
            addGoogleAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        addGoogleAd()
    }
}
