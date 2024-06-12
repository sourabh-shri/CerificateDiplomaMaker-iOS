//
//  SplashViewController.swift
//  CerificatesTemplates
//
//  Created by SMT Sourabh  on 07/06/24.
//  Copyright © 2024 Mobiona. All rights reserved.
//

import Foundation

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performSegue(withIdentifier: "StartApp", sender: self)
        }
    }
}
