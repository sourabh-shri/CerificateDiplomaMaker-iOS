//
//  ViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/1/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var data : Data!
    var templatesDict :NSMutableArray = []
    var thumbImgArray :NSMutableArray = []
    var selectedTempDict = NSDictionary()
    var image : UIImage!
    
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var thumbImgCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndecator.isHidden = false
        activityIndecator.startAnimating()
        setUpJsonFile()

        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(ViewController.Cancel))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = "Templates"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func Cancel(){
//        navigationController?.popToRootViewController(animated: true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 func setUpJsonFile() {
    
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
        setUpThumbImgArray(templatesDict)
        thumbImgCollectionView.delegate = self
        thumbImgCollectionView.dataSource = self
    }

    @IBAction func showTemplateDetails(_ sender: AnyObject) {
       // let passDict : NSDictionary = arrDict[sender.tag] as! NSDictionary
    }
    
    func setUpThumbImgArray(_ array:NSArray){
        for i in 0  ..< templatesDict.count {
//        thumbImgArray.add((templatesDict.value(forKey: "thumbImageUrl") as! NSArray).object(at: i))
        thumbImgArray.add((templatesDict.value(forKey: "thumbImageName") as! NSArray).object(at: i))
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if thumbImgArray.count != 0 {
            self.activityIndecator.stopAnimating()
            self.activityIndecator.isHidden = true
        }
        return thumbImgArray.count
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize
    {
        let cellSize : CGSize
        if UIScreen.main.bounds.size.width == 768.0 {
            cellSize  = CGSize(width: 340 , height: 340)
        }
        else if UIScreen.main.bounds.size.width == 375.0 {
            cellSize  = CGSize(width: 160 , height: 160)
        }
        else if UIScreen.main.bounds.size.width == 414.0 {
            cellSize  = CGSize(width: 180 , height: 180)
        }
        else {
            cellSize  = CGSize(width: 140 , height: 140)
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        if UIScreen.main.bounds.size.width == 768.0 {
            return UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        }
        else {
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCellID", for: indexPath)
        let bgImageUrlString : String = thumbImgArray.object(at: indexPath.row) as! String
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
       // imgView.image = UIImage.init(named: bgImageUrlString)
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let myThumb2 = UIImage.init(named: bgImageUrlString)?.resizeWith(width: 572.0)
        imgView.image = myThumb2
        
//        cellImgView = AutoLoaderImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
//        cellImgView.loadImage(atUrl: bgImageUrlString as String!, withPlaceholderImageNameFromResource: "certificatePlaceholder.png")
        cell.contentView.addSubview(imgView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTempDict = templatesDict[indexPath.row] as! NSDictionary
        let editCertVC = self.storyboard?.instantiateViewController(withIdentifier: "EditCertVC") as! EditCertificateViewController
        editCertVC.selectedTemplateData = selectedTempDict
        
        if indexPath.item == 0 {
            
            self.navigationController?.pushViewController(editCertVC, animated: true)
        }else {
            // Check if Pro version
            if Context.getInstance().isProVersion() == false {
                
                (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)

            }
            else {
                self.navigationController?.pushViewController(editCertVC, animated: true)
            }

        }
        
        
        
        
    }
}

