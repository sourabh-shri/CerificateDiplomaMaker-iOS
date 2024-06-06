//
//  CertificateDetailsViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 12/27/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class CertificateDetailsViewController: UIViewController,UIScrollViewDelegate {
    
    var passCertData : DBCertificate!
    var passTranscriptData : DBTranscript!
    
    @IBOutlet weak var certImgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var zoomBarBtn = UIBarButtonItem()
    var scaleBtnTag = 0
    var savedFrame = CGRect()
    var saveContentOffset = CGPoint()

    @IBOutlet weak var yValueOfCertImage: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        let defaults = UserDefaults.standard
        let name: String = defaults.object(forKey: "Name") as! String
        
        if name == "Transcript" {
            let fileName: String = passTranscriptData.value(forKey: "imageFilename") as! String
            let fullFilePath: String = Context.getInstance().getImageStorageFullpath(forFilename: fileName)
            var imgData:Data? = nil
            do { imgData = try Data(contentsOf:URL.init(fileURLWithPath: fullFilePath)) } catch {}
            if imgData == nil { imgData = passTranscriptData.value(forKey: "image") as? Data }
            if imgData != nil
            {
                certImgView.image = UIImage(data: imgData!, scale: 1)
            }
        }else {
            let fileName: String = passCertData.value(forKey: "imageFilename") as! String
            let fullFilePath: String = Context.getInstance().getImageStorageFullpath(forFilename: fileName)
            var imgData:Data? = nil
            do { imgData = try Data(contentsOf:URL.init(fileURLWithPath: fullFilePath)) } catch {}
            if imgData == nil { imgData = passCertData.value(forKey: "image") as? Data }
            if imgData != nil
            {
                certImgView.image = UIImage(data: imgData!, scale: 1)
            }
        }
        
        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(CertificateDetailsViewController.Cancel))
        navigationItem.leftBarButtonItem = backItem
        
       // zoomBarBtn = UIBarButtonItem(image:#imageLiteral(resourceName: "cDVC_ZoomIn"), landscapeImagePhone: #imageLiteral(resourceName: "cDVC_ZoomIn"), style: .plain, target: self, action: #selector(CertificateDetailsViewController.ScaleTheView))
        
        zoomBarBtn = UIBarButtonItem(image:#imageLiteral(resourceName: "cDVC_ZoomIn"), landscapeImagePhone: #imageLiteral(resourceName: "cDVC_ZoomIn"), style: .plain, target: self, action: #selector(zoomInNOut))
        
        navigationItem.rightBarButtonItem = zoomBarBtn
         scaleBtnTag = 1
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        certImgView.isHidden = true
    }
    
    
    @objc func zoomInNOut() {
        if scaleBtnTag == 1 {
            scaleBtnTag = 2
            zoomBarBtn.image = #imageLiteral(resourceName: "cDVC_ZoomOut")
            UIView.animate(withDuration: 0.6,
                           animations: {
                            
                            self.certImgView.transform = CGAffineTransform.identity
            },
                           completion: { _ in
                            UIView.animate(withDuration: 1) {
                                self.certImgView.transform = CGAffineTransform(scaleX: 2, y: 2)
                            }
            }) 
            scrollView.contentSize = CGSize(width:certImgView.frame.size.width * 1.5,
                                            height:certImgView.frame.size.height * 1.5)
            scrollView.contentInset = UIEdgeInsets(top: certImgView.frame.size.height/2, left: certImgView.frame.size.width/2, bottom: 0.0, right: 0.0)
            scrollView.isScrollEnabled = true
        }else if scaleBtnTag == 2 {
            scaleBtnTag = 1
            zoomBarBtn.image = #imageLiteral(resourceName: "cDVC_ZoomIn")
            UIView.animate(withDuration: 0.6,
                           animations: {
                            
                            self.certImgView.transform = CGAffineTransform(scaleX: 2, y: 2)
            },
                           completion: { _ in
                            UIView.animate(withDuration: 1) {
                                
                                self.certImgView.transform = CGAffineTransform.identity
                            }
            })
            scrollView.setContentOffset(saveContentOffset, animated: false)
            scrollView.isScrollEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedFrame = certImgView.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        saveContentOffset = scrollView.contentOffset
//        ScaleTheView()
//        self.automaticallyAdjustsScrollViewInsets = false
        certImgView.isHidden = false
    }

    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return certImgView;
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func passingCertData(_cert:DBCertificate) {
        passCertData = _cert
    }
    func passingTranscriptData(_trans:DBTranscript) {
        passTranscriptData = _trans
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
////        scrollView.isScrollEnabled = true
//        return certImgView
//    }
    
//    func zoomingTheScrollView() {
//        if(scrollView.zoomScale < scrollView.maximumZoomScale) {
//            scrollView.contentOffset = saveContentOffset
//            scrollView.zoomScale = (scrollView.maximumZoomScale + 0.1)
////            certImgView.bounds.origin.x = 0
//////            certImgView.frame.origin.y = 0
////            certImgView.bounds.origin.y = 0
//            certImgView.bounds.origin.y = -52
//            
//        }
//        else if(scrollView.zoomScale > scrollView.minimumZoomScale) {
//            scrollView.zoomScale = (scrollView.minimumZoomScale)
//        }
//    }
  
    @IBAction func editCertificate(_ sender: UIButton){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let defaults = UserDefaults.standard
        let name: String = defaults.object(forKey: "Name") as! String
        
        if name == "Transcript" {
            let tempVC = storyBoard.instantiateViewController(withIdentifier: "EditTranscriptVC") as! EditTranscriptViewController
            tempVC.updateView(_trans: passTranscriptData)
            self.navigationController?.pushViewController(tempVC, animated: true)
        }
        else {
            let tempVC = storyBoard.instantiateViewController(withIdentifier: "EditCertVC") as! EditCertificateViewController
            tempVC.updateView(_cert: passCertData)
            self.navigationController?.pushViewController(tempVC, animated: true)
        }
    }
    
    @objc func Cancel(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    func ScaleTheView() {
            if scaleBtnTag == 1 {
                print(scrollView.contentOffset)
                scrollView.setContentOffset(saveContentOffset, animated: false)
                let sx = UIScreen.main.bounds.size.width / certImgView.frame.size.width
                certImgView.transform = CGAffineTransform(scaleX: sx,y: sx)
                certImgView.frame.origin.x = 0.0
                certImgView.frame.origin.y = scrollView.frame.size.height/2.0 - certImgView.frame.size.height/2.0
                scrollView.isScrollEnabled = false
                zoomBarBtn.image = #imageLiteral(resourceName: "cDVC_ZoomIn")
                scaleBtnTag = 2
                print(scrollView.contentOffset)
                print(certImgView.frame)
            }
                
            else if scaleBtnTag == 2{
                scaleBtnTag = 1
                certImgView.transform = CGAffineTransform.identity
                certImgView.frame.origin.x = 0
                certImgView.frame.origin.y = 0
                zoomBarBtn.image = #imageLiteral(resourceName: "cDVC_ZoomOut")
                scrollView.contentSize = CGSize(width:savedFrame.size.width,height:scrollView.frame.size.height)
                scrollView.isScrollEnabled = true
            }
    }
}
