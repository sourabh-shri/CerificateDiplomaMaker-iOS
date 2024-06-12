//
//  TemplateAndTranscriptViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 12/14/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class TemplateAndTranscriptViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarBg.png"),for: .default)
        //navigationItem.title = "Create Diploma"
        
        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(TemplateAndTranscriptViewController.Cancel))
        
        navigationItem.leftBarButtonItem = backItem
        GoogleAdClass.shared.addGoogleAd()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func Cancel(){
        self.dismiss(animated: true, completion: nil)
    }

}
