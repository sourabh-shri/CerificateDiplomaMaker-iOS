//
//  HomeViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/16/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var data : Data!
    var templatesDict :NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      /*  let urlString = "http://54.213.28.200/diploma/diploma_templates.json"
        setUpJsonFile(urlString as NSString) */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpJsonFile("nothing")
    }
    
    func setUpJsonFile(_ urlString:NSString) {
        if let path = Bundle.main.path(forResource: "diploma_templates", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                self.parseDataFromJsonFile(data)
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func parseDataFromJsonFile(_ data:Data) {
        var json: AnyObject?
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options:[]) as! NSDictionary
        } catch {
            print(error)
            return
        }
        
        guard let data_dictionary = json as? NSDictionary else    {
            return
        }
        
        for i in 0  ..< (data_dictionary.value(forKey: "templates") as! NSArray).count
        {
            templatesDict.add((data_dictionary.value(forKey: "templates") as! NSArray) .object(at: i))
        }
        
        Context.getInstance().createTemplateDictionary(templatesDict)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navbarBg.png"),for: .default)
        navigationItem.title = "Diploma"
    }

    @IBAction func rateAppClicked(_ sender: UIButton) {
        
        let urlStr: String = Context.getInstance().getValue(APP_REVIEW_URL_KEY) as String
        UIApplication.shared.openURL(URL(string: urlStr)!)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
