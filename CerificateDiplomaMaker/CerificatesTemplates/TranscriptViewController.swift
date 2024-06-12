//
//  TranscriptViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 1/3/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TranscriptViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var thumbTranscriptCollectionView: UICollectionView!
    
    var transcriptsDict :NSMutableArray = []
    var thumbImgArray :NSMutableArray = []
    var selectedTranscriptDict = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(TranscriptViewController.Cancel))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = "Transcripts"
        setUpJsonFile()
        GoogleAdClass.shared.showAd(controller: self.navigationController!)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func Cancel(){
        //        navigationController?.popToRootViewController(animated: true)
        _ = navigationController?.popViewController(animated: true)
    }

    func setUpJsonFile() {
        
        if let path = Bundle.main.path(forResource: "diploma_transcripts", ofType: "json") {
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
        print("trans....\(data_dictionary)")
        for i in 0  ..< (data_dictionary.value(forKey: "transcripts") as! NSArray).count
        {
            transcriptsDict.add((data_dictionary.value(forKey: "transcripts") as! NSArray) .object(at: i))
        }
        print("trans....\(transcriptsDict)")
        Context.getInstance().createTemplateDictionary(transcriptsDict)
        setUpThumbImgArray(transcriptsDict)
        thumbTranscriptCollectionView.dataSource = self
        thumbTranscriptCollectionView.delegate = self
    }
    
    
    func setUpThumbImgArray(_ array:NSArray){
        for i in 0  ..< transcriptsDict.count {

            thumbImgArray.add((transcriptsDict.value(forKey: "thumbImageName") as! NSArray).object(at: i))
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     if thumbImgArray.count != 0 {
//            self.activityIndecator.stopAnimating()
//            self.activityIndecator.isHidden = true
        }
        return thumbImgArray.count
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize
    {
        let cellSize : CGSize
        if UIScreen.main.bounds.size.width == 768.0 {
            cellSize  = CGSize(width: 340 , height: 440)
        }
        else if UIScreen.main.bounds.size.width == 375.0 {
            cellSize  = CGSize(width: 160 , height: 210)
        }
        else if UIScreen.main.bounds.size.width == 414.0 {
            cellSize  = CGSize(width: 180 , height: 230)
        }
        else {
            cellSize  = CGSize(width: 140 , height: 210)
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TranscriptCellID", for: indexPath)
        let bgImageUrlString : String = thumbImgArray.object(at: indexPath.row) as! String
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        NSLog("image \(bgImageUrlString)")
        imgView.image = UIImage.init(named: bgImageUrlString)
        //imgView.image = UIImage.init(named: "2.png")
        cell.contentView.addSubview(imgView)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let defaults = UserDefaults.standard
//        defaults.set(0, forKey: "gradeCellCount")
        
        selectedTranscriptDict = transcriptsDict[indexPath.row] as! NSDictionary
        let editTranscriptVC = self.storyboard?.instantiateViewController(withIdentifier: "EditTranscriptVC") as! EditTranscriptViewController
//        editTranscriptVC.selectedTemplateData = selectedTranscriptDict
        editTranscriptVC.selectedTranscriptData = selectedTranscriptDict
        
        if indexPath.item == 0 {
            
            self.navigationController?.pushViewController(editTranscriptVC, animated: true)
        }else {
            // Check if Pro version
            //if Context.getInstance().isProVersion() == false {
                
              //  (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)
                
         //   }
         //   else {
                self.navigationController?.pushViewController(editTranscriptVC, animated: true)
           // }
        }
    }
}
