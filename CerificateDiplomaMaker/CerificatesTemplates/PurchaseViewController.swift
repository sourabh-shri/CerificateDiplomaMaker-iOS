//
//  PurchaseViewController.swift
//  CerificatesTemplates
//
//  Created by Apple on 25/11/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
import StoreKit


class PurchaseViewController: UIViewController {

    var products = [SKProduct]()
    var buyNowPending = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Upgrade Your Account"
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
   
    
    func reload() {
        products = []
        IAPProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                if self.buyNowPending { self.handleBuyNowClicked() }
            } else {
                let alertController = UIAlertController(
                    title: "Product Request Failed",
                    message: "Failed to request Products from Apple Server.\n\nCheck your Internet connection.\n\nOr your Apple Account might be Invalid!",
                    preferredStyle: UIAlertController.Style.alert)
                let noAction = UIAlertAction(
                    title: "OK", style: UIAlertAction.Style.default) {
                    (action) -> Void in
                }
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }

    func handleBuyNowClicked() {
        if self.products.count > 0 {
            buyNowPending = false;
            IAPProducts.store.buyProduct(self.products[0])
        } else {
            buyNowPending = true;
            reload()
        }
    }
    
    @IBAction func buyNowClicked(_ sender: RoundButton) {
        handleBuyNowClicked()
    }
    
    
    @IBAction func restorePurchasesClicked(_ sender: RoundButton) {
        IAPProducts.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else {
            return
        }
        
        if productID == IAPProducts.CertificateMakerFreeIAP {
            Context.getInstance().enableProVersion()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    

}
