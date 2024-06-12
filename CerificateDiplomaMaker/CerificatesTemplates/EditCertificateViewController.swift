 //
//  EditCertificateViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/29/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
import CoreData
import Photos

class EditCertificateViewController: UIViewController,UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,SwiftHSVColorPickerDelegate,SHFSignatureProtocol,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    var updateViewInfo : NSString!
    var scrollView: UIScrollView!
    var containerView : UIView!
    var templateImageView: UIImageView!
    var image : UIImage!
    
    var selectedTemplateData = NSDictionary()
    
    var textInfoDict = NSDictionary()
    var textViewInfoDict = NSDictionary()
    var imgInfoDict  = NSDictionary()
    
    var storeTextFInstance = NSMutableDictionary()
    var storeImgVInstance = NSMutableDictionary()
    var storeTextVInstance = NSMutableDictionary()
    
    var storeCreateImgPicker = NSMutableDictionary()
    
    var storeCurrentTxtField : UITextField!
    var storeCurrentTextView : UITextView!
    var storeCurrentImgView = String()
    
    var logoImageView : UIImageView!
    var signImageView : UIImageView!
    
    var logoDict = NSDictionary()
    var signatureDict = NSDictionary()
    
    let signImgPicker = UIImagePickerController()
    let logoImgPicker = UIImagePickerController()
    
    var contentScrollView = UIScrollView()
    var storeYConstraintOfContentSV = CGFloat()
    
    
    var btnTag = 0
    var saveItem = UIBarButtonItem()
    
    var customizingView = CustomizingView()
    
    var fontSize = CGFloat()
    var selectedColor = UIColor()
    var customizeableField = UITextField()
    var customizeableView = UITextView()

    
    var selectedFontName = String()

    var fontArray : NSMutableArray=[]
    var storeSignImgDat = String()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    var savedFrame = CGRect()
    var saveContentOffset = CGPoint()
    var cert : DBCertificate!
    
    
    var dateTF = CustomTextField()
    let albumName = "Diploma"
    
    
    let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var signImg = UIImage()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneDatePicker: UIButton!
    @IBOutlet weak var datePickerBackView: UIView!
    
    var storeSelectedEditTFData = String()
    var storeSelectedEditTVData = String()

    @IBOutlet weak var signView: SHFSignatureView!
    @IBOutlet weak var signAndSealBtnHolderStackView: UIStackView!
    @IBOutlet weak var uploadSealContainerView: UIView!
    
    
    var storeEditTextFieldInstance = NSMutableDictionary()
    var storeEditTextViewInstance = NSMutableDictionary()

    @IBOutlet weak var selcetedSealImage: UIImageView!
    
    var sealsArray : NSArray = ["seal01.png","seal02.png","seal03.png","seal04.png","seal05.png","seal06.png","seal07.png","seal08.png","seal09.png","seal10.png","seal11.png","seal12.png"]
    
    var storeTFAndTVTextDefaults = UserDefaults.standard
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        signView.delegate = self
        hideDatePicker()
        activityInd.isHidden = false
        activityInd.startAnimating()
        
        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(EditCertificateViewController.Cancel))
        
        navigationItem.leftBarButtonItem = backItem
        
        saveItem = UIBarButtonItem(image:UIImage(named: "nav_save_btn.png"), landscapeImagePhone: UIImage(named: "nav_save_btn.png"), style: .plain, target: self, action: #selector(EditCertificateViewController.Save))
        saveItem.tintColor = UIColor.white
        navigationItem.setRightBarButton(saveItem, animated: true)
        
        if cert == nil {
            navigationItem.title = "New"
        }
        else {
            navigationItem.title = cert.certificateTitle
        }
        saveItem.isEnabled = false

        logoImgPicker.delegate = self
    
        if selectedTemplateData.count != 0 {
            loadBgImgView(bgImageUrlString: selectedTemplateData.value(forKey: "bgImageName") as! NSString, bgImageWidth: self.selectedTemplateData.value(forKey: "widthInPixels")! as! NSNumber, bgImageHeight: self.selectedTemplateData.value(forKey: "heightInPixels")! as! NSNumber)
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if contentScrollView.frame.origin.y == storeYConstraintOfContentSV {
//                contentScrollView.frame.origin.y -= keyboardSize.height-30
//                customizingView.frame.origin.y -= keyboardSize.height-30
//            }
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardSize.height)
//            contentScrollView.frame.origin.y += keyboardSize.height-30
//            customizingView.frame.origin.y += keyboardSize.height-30
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func hideKeyboard() {
        for value in storeEditTextFieldInstance.allValues {
            (value as! UITextField).resignFirstResponder()
        }
        
        for value in storeEditTextViewInstance.allValues {
            (value as! UITextView).resignFirstResponder()
        }
        
//        let tf = storeTextFInstance["name"] as! UITextField
//        tf.resignFirstResponder()
//        (storeTextFInstance["name"] as! UITextField).resignFirstResponder()
    }
    
    @objc func showDatePicker() {
        hideKeyboard()
        self.view.bringSubviewToFront(datePickerBackView)
        self.view.bringSubviewToFront(doneDatePicker)
        self.view.bringSubviewToFront(datePicker)
        
        datePickerBackView.isHidden = false
        doneDatePicker.isHidden = false
        datePicker.isHidden = false
    }
    
    func hideDatePicker() {
        datePickerBackView.isHidden = true
        doneDatePicker.isHidden = true
        datePicker.isHidden = true
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let tField = storeTextFInstance["date"] as! UITextField
        tField.text = dateFormatter.string(from: datePicker.date)
        dateTF.text = tField.text
    }
    
    @IBAction func cancelDatePicker(_ sender: AnyObject) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let tField = storeTextFInstance["date"] as! UITextField
        tField.text = dateFormatter.string(from: datePicker.date)
        dateTF.text = tField.text
        hideDatePicker()
    }
    
    @objc func changeFontSizeTF(_ txtField:UITextField){
        let fontSize1: CGFloat = CGFloat((txtField.text! as NSString).doubleValue)
        fontSize = fontSize1
        setTextFieldFont(fontSize1)
        customizingView.fontStepper.value = Double(fontSize1)
    }
    
    func setTextFieldFont(_ fontSize : CGFloat) {
        if customizingView.selectedCustomizeableTFOrTV == "TextFieldSelected" {
            customizeableField.font = UIFont(name: selectedFontName, size: fontSize)
        }
        
        else if customizingView.selectedCustomizeableTFOrTV == "TextViewSelected" {
            customizeableView.font = UIFont(name: selectedFontName, size: fontSize)
        }

    }
    
    func loadBgImgView(bgImageUrlString:NSString , bgImageWidth:NSNumber ,bgImageHeight:NSNumber ) {
        
     /*   DispatchQueue.global(qos: .background).async {
            let imageURL = URL(string: bgImageUrlString as String)
            let data:Data?  = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.async(execute: {
                if data == nil {
                    print("error")
                } else {
                    self.image = UIImage(data: data!)
                    guard let _ = self.image else {
                        return
                    }
                    self.setUpScrollView(self.image, bgWidth: CGFloat((bgImageWidth as AnyObject) .doubleValue), bgHeight: CGFloat((bgImageHeight as AnyObject) .doubleValue))
                    self.saveItem.isEnabled = true
                    self.activityInd.isHidden = true
                    self.activityInd.stopAnimating()
                }
            });
        } */
        
//       self.image = UIImage(data: data!)
        
       /* let  str = bgImageUrlString.contains("http://54.213.28.200/diploma/")
        if str == true {
//            let imgStr = bgImageUrlString.replacingOccurrences(of: "http://54.213.28.200/diploma/", with: "", options: NSString.CompareOptions.literal, range:nil)
            
            let imgStr = bgImageUrlString.replacingOccurrences(of: "http://54.213.28.200/diploma/",with: "")
            print(imgStr)
            self.image = UIImage.init(named: imgStr as String)
        }
        
        else {
            self.image = UIImage.init(named: bgImageUrlString as String)
        } */
        
        self.image = UIImage.init(named: bgImageUrlString as String)

        self.setUpScrollView(self.image, bgWidth: CGFloat((bgImageWidth as AnyObject) .doubleValue), bgHeight: CGFloat((bgImageHeight as AnyObject) .doubleValue))
        self.saveItem.isEnabled = true
        self.activityInd.isHidden = true
        self.activityInd.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == customizingView.fontSizeTxtField {
            customizingView.fontSizeTxtField.text = ""
        }
        
        else if textField == customizingView.txtColorHexCode {
            customizingView.txtColorHexCode.text = "#"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == customizingView.fontSizeTxtField {
            let fontSize1: CGFloat = CGFloat((textField.text! as NSString).doubleValue)
            customizingView.fontSizeTxtField.text = "\(fontSize1)"
        }
            
        else if textField == customizingView.txtColorHexCode {
            let color = hexStringToUIColor(textField.text! as String)
            customizingView.colorPicker.setViewColor(color)
        }
        else {
            let tF : CustomTextField = textField as! CustomTextField
            print(tF.txtFData)
            let textF = storeTextFInstance.object(forKey: tF.txtFData as! String) as! UITextField
            textF.text = tF.text
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == customizingView.fontSizeTxtField {
        }
            
        else if textField == customizingView.txtColorHexCode {
            if textField == customizingView.txtColorHexCode && textField.text?.count == 0 {
                customizingView.txtColorHexCode.text = "#"
            }
            else if textField == customizingView.txtColorHexCode {
                // changing 6 to 8
                if (textField.text?.count)! > 6 {
                    return false
                }
            }
        }
        else {
            let tF : CustomTextField = textField as! CustomTextField
            print(tF.txtFData)
            let textF = storeTextFInstance.object(forKey: tF.txtFData as! String) as! UITextField
            textF.text = tF.text
            if textF.text == "" {
                tF.text = ""
            }
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        let tV : CustomTextView = textView as! CustomTextView
        let textV = storeTextVInstance.object(forKey: tV.txtVData as! String) as! UITextView
        if textV.text == "Enter a description" {
            tV.text = ""
        }
        textV.text = tV.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
            let tV : CustomTextView = textView as! CustomTextView
            let textV = storeTextVInstance.object(forKey: tV.txtVData as! String) as! UITextView
            textV.text = tV.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let tV : CustomTextView = textView as! CustomTextView
        let textV = storeTextVInstance.object(forKey: tV.txtVData as! String) as! UITextView
        if textV.text == "" {
            tV.text = "Enter a description"
        }
        textV.text = tV.text
    }
    
    @objc func Cancel() {
        
        if datePickerBackView.isHidden == false {
            
            hideDatePicker()
        }
        else if signView.isHidden == false {
            
            self.blurEffectView.isHidden = true
            signView.clear()
            hideChooseSealAndSignVIewView()
        }
        else {
            _ = navigationController?.popViewController(animated: true)
        }
//        if cert != nil {
//            _ = navigationController?.popViewController(animated: true)
//        }
//        else {
//           _ = navigationController?.popToViewController(self.navigationController!.viewControllers[1] as! CertificatesTableViewController, animated: true)
//        }
    }
    
    @objc func Save(){
        
        hideKeyboard()
        // Check if Pro version
      if Context.getInstance().isProVersion() == false {
            // Fetch Data from Certificate
            let fetchRequest2: NSFetchRequest<DBCertificate> = DBCertificate.fetchRequest()
            // Edit the entity name as appropriate.
            let entity2 = NSEntityDescription.entity(forEntityName: "DBCertificate", in: self.managedObjContext)
            fetchRequest2.entity = entity2
            var certCount:Int = 0
            do {
                let fetchObj2 = try self.managedObjContext.fetch(fetchRequest2)
                certCount = fetchObj2.count
            } catch{
                print(error.localizedDescription)
            }
        if certCount > Int(MAX_ALLOWED_CERTS_IN_FREE_VERSION) {
             //   (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)
            
             //   return
         }
    }
        print("aasasa")
        
        let defaults = UserDefaults.standard
        defaults.set("Certificate", forKey: "Name")
        
        
        let sizeOfContent = templateImageView.frame.size.height + scrollView.frame.origin.y+10
        scrollView.contentSize.height = sizeOfContent
        scrollView.contentSize.width = templateImageView.bounds.size.width
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        saveOrUpdateTheFileInDB()
    }
    
    func saveOrUpdateTheFileInDB() {
        if self.cert == nil {
            self.cert = NSEntityDescription.insertNewObject(forEntityName: "DBCertificate", into: self.managedObjContext) as! DBCertificate
            self.storeCertificateDatatoDB(self.cert)
            self.storeImgFieldAndTfAndTviewData(self.cert)
        }
        else {
            self.updateCertificateDatatoDB(self.cert)
            self.updateImgfTfAndTVData(self.cert)
        }
        
        let date :Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd_yyyy'_'HH:mm:ss"
        var savedName = ""
    
        let tField = storeTextFInstance["nameOfCandidate"] as! UITextField
        savedName = tField.text!
        
        let certTitle = "\(savedName) \(dateFormatter.string(from: date))"

        let sampleImage = UIImage.renderUIViewToImage(containerView)
        let sampleThumbnailImage = Context.getInstance().resize(sampleImage, to: CGSize(width: 350, height: 280))
        let imgData : Data = sampleImage.pngData()!
        let imgThumbnailData : Data = sampleThumbnailImage!.pngData()!
        let fileName: String = Context.getInstance().getUniqueName(withPrefix: "Certificate", withSuffix: ".png")
        let fullFilePath: String = Context.getInstance().getImageStorageFullpath(forFilename: fileName)
        do {
            try imgData.write(to: URL(fileURLWithPath: fullFilePath), options: .atomic)
        } catch {
            print(error)
        }
        let fileThumbnailName: String = "Thumb\(fileName)"
        let fullThumbnailFilePath: String = Context.getInstance().getImageStorageFullpath(forFilename: fileThumbnailName)
        do {
            try imgThumbnailData.write(to: URL(fileURLWithPath: fullThumbnailFilePath), options: .atomic)
        } catch {
            print(error)
        }
        self.cert.setValue(imgData, forKey: "image")
        self.cert.setValue(fileName, forKey: "imageFilename")
        self.cert.setValue(fileThumbnailName, forKey: "imageThumbFilename")

        self.cert.setValue(certTitle, forKey: "certificateTitle")
        do {
            try self.managedObjContext.save()
            // certificate show Name
        }catch {
            print(error.localizedDescription)
        }
        
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            // saving images in Photos
            let defaults = UserDefaults.standard
            let fetchOptions: PHFetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            print(fetchOptions.predicate!)
            var collection: PHFetchResult<AnyObject>
            let value = defaults.value(forKey: "Authorization") as? String
            if  "NO" == value {
                collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil) as! PHFetchResult<AnyObject>
            }else {
                collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions) as! PHFetchResult<AnyObject>
            }
            
            if let firstObject: AnyObject = collection.firstObject {
                return firstObject as! PHAssetCollection
            }
            return nil
        }
        
        let image = UIImage(data: imgData)
        if let assetCollection = fetchAssetCollectionForAlbum() {
            createPhotoOnAlbum(photo: image!, album: assetCollection)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            }) { success, _ in
                if success {
                    let assetCollection = fetchAssetCollectionForAlbum()
                    self.createPhotoOnAlbum(photo: image!, album: assetCollection!)
                }
            }
        }
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let tempVC = storyBoard.instantiateViewController(withIdentifier: "CertificatesTableViewController") as! CertificatesTableViewController
        self.navigationController?.pushViewController(tempVC, animated: true)
    }
    
    func storeCertificateDatatoDB(_ cert: DBCertificate) {
        let newCertificateObject = cert
        print(newCertificateObject)
        newCertificateObject.setValue(Date(), forKey: "dateCreated")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "templateId"), forKey: "templateId")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "organization"), forKey: "organization")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "bgImageName"), forKey: "templateBgImageUrl")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "widthInPixels"), forKey: "templateWidthInPixels")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "heightInPixels"), forKey: "templateHeightInPixels")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "name"), forKey: "templateName")
    }
    func storeImgFieldAndTfAndTviewData(_ cert: DBCertificate) {
        let newCertificateObject = cert
        
        // store tF Data
        if let textFieldArray : NSArray = selectedTemplateData.value(forKey: "textFields") as? NSArray {
            for value in textFieldArray {
                let newTextFieldObject = NSEntityDescription.insertNewObject(forEntityName: "DBTextField", into: managedObjContext) as! DBTextField
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let tField = storeTextFInstance[name] as! UITextField
                
                passTFData(newTextFieldObject, txtField: tField)
                newTextFieldObject.setValue(name, forKey: "templateName")
                newCertificateObject.addToTextFields(newTextFieldObject)
                storeTFAndTVTextDefaults.set(tField.text, forKey: name as String)
                // if the user want to write in certificate remove place holder text  to nil befor saving
                if tField.text == "" {
                    tField.placeholder = ""
                }
            }
        }
        // store imgF Data
        if let imgFieldsArray : NSArray = selectedTemplateData.value(forKey: "imageFields") as? NSArray {
            for value in imgFieldsArray {
                let newImgFieldObject = NSEntityDescription.insertNewObject(forEntityName: "DBImageField", into: managedObjContext) as! DBImageField
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let imgView = storeImgVInstance[name] as! UIImageView
                passIMGFieldData(newImgFieldObject, imgView: imgView)
                newImgFieldObject.setValue(name, forKey: "templateName")
                newCertificateObject.addToImageFields(newImgFieldObject)
            }
        }
        // store textView Data
        if let textViewArray : NSArray = selectedTemplateData.value(forKey: "textViewFields") as? NSArray {
            for value in textViewArray {
                let newTextViewObject = NSEntityDescription.insertNewObject(forEntityName: "DBTextView", into: managedObjContext) as! DBTextView
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let tView = storeTextVInstance[name] as! UITextView
                passTVData(newTextViewObject, txtView: tView)
                newTextViewObject.setValue(name, forKey: "templateName")
                newCertificateObject.addToTextViews(newTextViewObject)
                storeTFAndTVTextDefaults.set(tView.text, forKey: name as String)
                if tView.text == "Enter a description" {
                    tView.text = ""
                }
            }
        }
    }
    
    
    func updateCertificateDatatoDB(_ cert: DBCertificate) {
        let newCertificateObject = cert
        newCertificateObject.setValue(Date(), forKey: "dateCreated")
        newCertificateObject.setValue(cert.templateId, forKey: "templateId")
        newCertificateObject.setValue(cert.organization, forKey: "organization")
        newCertificateObject.setValue(cert.templateBgImageUrl, forKey: "templateBgImageUrl")
        newCertificateObject.setValue(cert.templateWidthInPixels, forKey: "templateWidthInPixels")
        newCertificateObject.setValue(cert.templateHeightInPixels, forKey: "templateHeightInPixels")
        newCertificateObject.setValue(cert.templateName, forKey: "templateName")
    }
    
    
    func updateImgfTfAndTVData(_ cert : DBCertificate) {
        let newCertificateObject = cert
        
        for txtField in (cert.textFields?.allObjects)!{
            let name: String = (txtField as! DBTextField).templateName!
            passTFData(txtField as! DBTextField, txtField: storeTextFInstance[name] as! UITextField)
            let tF = storeTextFInstance[name] as! UITextField
            storeTFAndTVTextDefaults.set(tF.text, forKey: name as String)
            (txtField as! DBTextField).setValue(name, forKey: "templateName")
            newCertificateObject.addToTextFields(txtField as! DBTextField)
            if tF.text == "" {
                tF.placeholder = ""
            }
        }
        
        for imgField in (cert.imageFields?.allObjects)!  {
            let name : String = (imgField as! DBImageField).templateName!
            let imgView = storeImgVInstance[name] as! UIImageView
            passIMGFieldData(imgField as! DBImageField, imgView: imgView)
            (imgField as! DBImageField).setValue(name, forKey: "templateName")
            newCertificateObject.addToImageFields(imgField as! DBImageField)
        }
        
        for textView in (cert.textViews?.allObjects)!  {
            let name : String = (textView as! DBTextView).templateName!
            passTVData(textView as! DBTextView, txtView: storeTextVInstance[name] as! UITextView)
            let tV = storeTextVInstance[name] as! UITextView
            storeTFAndTVTextDefaults.set(tV.text, forKey: name as String)
            (textView as! DBTextView).setValue(name, forKey: "templateName")
            newCertificateObject.addToTextViews(textView as! DBTextView)
            if tV.text == "Enter a description" {
                tV.text = ""
            }
        }
    }
    
    
    func retriveFontFace(_ txtField:UITextField) -> String {
        var fontFace : String = ""
        if txtField.font!.fontName.range(of: "-") != nil {
            fontFace = txtField.font!.fontName.replacingOccurrences(of: txtField.font!.familyName + "-", with: "")
        }
        return fontFace
    }
    
    func retriveFontFace2(_ txtView:UITextView) -> String {
        var fontFace : String = ""
        if txtView.font!.fontName.range(of: "-") != nil {
            fontFace = txtView.font!.fontName.replacingOccurrences(of: txtView.font!.familyName + "-", with: "")
        }
        return fontFace
    }
    
    
    func passTFData(_ dbTf: DBTextField , txtField : UITextField) {
        let fontFace = retriveFontFace(txtField)
        let hexTextColor = hexStringFromUIColor(txtField.textColor!)
        dbTf.setValue(txtField.frame.origin.x, forKey: "x")
        dbTf.setValue(txtField.frame.origin.y, forKey: "y")
        dbTf.setValue(txtField.frame.size.width, forKey: "widthInPixels")
        dbTf.setValue(txtField.frame.size.height, forKey: "heightInPixels")
        
        dbTf.setValue(txtField.font!.familyName, forKey: "fontFamily")
        dbTf.setValue(txtField.font!.pointSize, forKey: "fontSize")
        dbTf.setValue(fontFace, forKey: "fontFace")
        dbTf.setValue(hexTextColor, forKey: "fontColorHex")
        dbTf.setValue(txtField.text, forKey: "content")
        dbTf.setValue(txtField.placeholder, forKey: "placeholder")
    }
    
    
    func passTVData(_ dbTf: DBTextView , txtView : UITextView) {
        let fontFace = retriveFontFace2(txtView)
        let hexTextColor = hexStringFromUIColor(txtView.textColor!)
        dbTf.setValue(txtView.frame.origin.x, forKey: "x")
        dbTf.setValue(txtView.frame.origin.y, forKey: "y")
        dbTf.setValue(txtView.frame.size.width, forKey: "widthInPixels")
        dbTf.setValue(txtView.frame.size.height, forKey: "heightInPixels")
        dbTf.setValue(txtView.font!.familyName, forKey: "fontFamily")
        dbTf.setValue(txtView.font!.pointSize, forKey: "fontSize")
        dbTf.setValue("Enter Your Description", forKey: "placeholder")
        dbTf.setValue(fontFace, forKey: "fontFace")
        dbTf.setValue(hexTextColor, forKey: "fontColorHex")
        dbTf.setValue(txtView.text, forKey: "content")
    }
    
    
    func passIMGFieldData(_ dbIf:DBImageField , imgView : UIImageView) {
        dbIf.setValue(imgView.frame.size.height, forKey: "heightInPixels")
        //let imgData : Data? = UIImageJPEGRepresentation(imgView.image!,1.0)
        let imgData : Data? = imgView.image!.pngData()
        dbIf.setValue(imgData, forKey: "image")
        dbIf.setValue(imgView.frame.size.width, forKey: "widthInPixels")
        dbIf.setValue(imgView.frame.origin.x, forKey: "x")
        dbIf.setValue(imgView.frame.origin.y, forKey: "y")
    }
    
    
    // set up scroll view based on template image
    func setUpScrollView(_ bgImage:UIImage,bgWidth:CGFloat,bgHeight:CGFloat) {
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.frame.origin.y = 70.0
        view.addSubview(scrollView)
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight))
        templateImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight))
        templateImageView.image = bgImage
        templateImageView.contentMode = .scaleAspectFit
        
        let sizeOfContent = templateImageView.frame.size.height + scrollView.frame.origin.y+10
        scrollView.contentSize.height = sizeOfContent
        scrollView.contentSize.width = templateImageView.bounds.size.width
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = false
        containerView.addSubview(templateImageView)
        
        saveContentOffset = scrollView.contentOffset
        
        scrollView.addSubview(containerView)
        containerView.backgroundColor = UIColor.clear
        scrollView.backgroundColor = UIColor.clear
        savedFrame = containerView.frame
        
        if selectedTemplateData.count != 0 {
            fetchTextFieldData()
            fetchImageFieldsData()
            fetchTextViewData()
        }
            
        else {
            for txtField in (cert.textFields?.allObjects)!{
                updateAndBuildTf(txtField: txtField as AnyObject)
            }
            for txtView in (cert.textViews?.allObjects)!{
                updateAndBuildTV(txtView: txtView as AnyObject)
            }
            
            for imgField in (cert.imageFields?.allObjects)!  {
                let name : String = (imgField as! DBImageField).templateName!
                self.image = UIImage(data: (imgField as! DBImageField).image! as Data)
                let wx = (imgField as! DBImageField).x!
                let wy = (imgField as! DBImageField).y!
                let ww = (imgField as! DBImageField).widthInPixels!
                let wh = (imgField as! DBImageField).heightInPixels!
                
                let x1 : CGFloat = CGFloat((wx as AnyObject) .doubleValue)
                let y1 : CGFloat = CGFloat((wy as AnyObject) .doubleValue)
                let w1 : CGFloat = CGFloat((ww as AnyObject) .doubleValue)
                let h1 : CGFloat = CGFloat((wh as AnyObject) .doubleValue)
                
                let imgView:UIImageView = UIImageView(frame: CGRect(x: x1, y: y1, width: w1, height: h1))
                imgView.image = self.image
                containerView.addSubview(imgView)
                let editImgBtn = CustomUIButton(frame: CGRect(x: imgView.frame.origin.x, y: imgView.frame.origin.y, width: imgView.frame.size.width, height: imgView.frame.size.height))

                containerView.addSubview(editImgBtn)
                editImgBtn.btnData = name as NSString
                
                if editImgBtn.btnData as! String == "logo" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                }
                else if editImgBtn.btnData as! String == "signature" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControl.Event.touchUpInside)
                }
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                storeImgVInstance[name] = imgView
                storeCreateImgPicker[name] = imgPicker
            }
        }
        
        scrollView.contentOffset = saveContentOffset
        let sx = UIScreen.main.bounds.size.width / containerView.frame.size.width
        containerView.transform = CGAffineTransform(scaleX: sx,y: sx)
        containerView.frame.origin.x = savedFrame.origin.x
        containerView.frame.origin.y = 0
        scrollView.isScrollEnabled = false
        print(containerView)
        let height = containerView.frame.size.height + scrollView.frame.origin.y
        storeYConstraintOfContentSV = height+5
        setUpEditContentScrollView(height)
    }
    
    func setUpEditContentScrollView(_ height:CGFloat) {
        contentScrollView = UIScrollView(frame: self.view.frame)
        contentScrollView.frame.origin.y = storeYConstraintOfContentSV
        contentScrollView.frame.size.height = self.view.frame.size.height - height
        view.addSubview(contentScrollView)
        contentScrollView.backgroundColor = UIColor(red: 35/255, green: 42/255, blue: 64/255, alpha: 1)
        contentScrollView.contentOffset = .zero
        contentScrollView.contentSize.height = self.view.frame.size.height - height
        contentScrollView.contentSize.width = self.view.frame.size.width
        contentScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentScrollView.bounces = false
        var yValue : CGFloat = -40
        
        if selectedTemplateData.count != 0 {
            if let textFieldArray : NSArray = selectedTemplateData.value(forKey: "textFields") as? NSArray {
                for value in textFieldArray {
                    let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                    let tField = storeTextFInstance[name] as! UITextField
                    let textField = CustomTextField(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30 - 35 , height: 35))
                    let customizeBtn = CustomUIButton(frame:CGRect(x:15+textField.frame.width , y:textField.frame.origin.y-1 , width : 35 , height: 35+2))
                    customizeBtn.btnData = name
                    customizeBtn.setBackgroundImage(#imageLiteral(resourceName: "customizeBtn"), for: .normal)
                    customizeBtn.addTarget(self, action: #selector(EditCertificateViewController.customizeTheTextField(_:)), for: UIControl.Event.touchUpInside)

                    contentScrollView.addSubview(textField)
                    contentScrollView.addSubview(customizeBtn)
                    textField.delegate = self
                    textField.placeholder = tField.placeholder
                    textField.text = tField.text
                    textField.txtFData = name
                    textField.autocorrectionType = UITextAutocorrectionType.no
                    textField.returnKeyType = UIReturnKeyType.done
                    textField.textAlignment = .left
                    textField.textColor = UIColor.white
                    textField.backgroundColor = UIColor(red: 47/255, green: 53/255, blue: 75/255, alpha: 1)
                    textField.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                if name == "date" {
                  let dateBtn = CustomUIButton(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30 - 35 , height: 35))
                   dateBtn.btnData = name
                    dateBtn.addTarget(self, action: #selector(EditCertificateViewController.showDatePicker), for: UIControl.Event.touchUpInside)
                  contentScrollView.addSubview(dateBtn)
                    dateTF = textField
                    }
                 yValue = yValue + 30 + 10
                storeEditTextFieldInstance[name] = textField
                }
                loadCustomizingView()
                customizingView.fontSizeTxtField.delegate = self
                customizingView.txtColorHexCode.delegate = self
                customizingView.colorPicker.delegate = self

            }
            
            // setUpTextViews
            if let textViewArray : NSArray = selectedTemplateData.value(forKey: "textViewFields") as? NSArray {
                for value in textViewArray {
                    let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                    let tView = storeTextVInstance[name] as! UITextView
                    let textView = CustomTextView(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30-35 , height: 35*3))
                    let customizeBtn = CustomUIButton(frame:CGRect(x:15+textView.frame.size.width , y:yValue-1 , width : 35 , height: 35+2))
                    customizeBtn.btnData = name
                    customizeBtn.setBackgroundImage(#imageLiteral(resourceName: "customizeBtn"), for: .normal)
                    customizeBtn.addTarget(self, action: #selector(EditCertificateViewController.customizeTheTextView(_:)), for: UIControl.Event.touchUpInside)
                    contentScrollView.addSubview(customizeBtn)
                    contentScrollView.addSubview(textView)
                    textView.delegate = self
                    textView.txtVData = name
                    textView.text = tView.text
                    textView.autocorrectionType = UITextAutocorrectionType.no
                    textView.returnKeyType = UIReturnKeyType.done
                    textView.textAlignment = .left
                    textView.textColor = UIColor.white
                    textView.backgroundColor = UIColor(red: 47/255, green: 53/255, blue: 75/255, alpha: 1)
                    yValue = yValue + 35*3 + 10
                    storeEditTextViewInstance[name] = textView
                }
            }
            
            // setUpImageViews
            if let imgFieldsArray : NSArray = selectedTemplateData.value(forKey: "imageFields") as? NSArray {
                for value in imgFieldsArray {
                    let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                    let imgPressBtn = CustomUIButton(frame:CGRect(x:15 , y:yValue+10 , width : contentScrollView.frame.width-30 , height: 35))
//                    imgPressBtn.addTarget(self, action: #selector(TemplateVIewController.OpenGalleryForLogo(_:)), for: UIControlEvents.touchUpInside)
                    contentScrollView.addSubview(imgPressBtn)
                    imgPressBtn.btnData = name
                    if imgPressBtn.btnData as! String == "logo" {
                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                    }
//                    else if imgPressBtn.btnData as! String == "signature" {
//                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControlEvents.touchUpInside)
//                    }
                    if (imgPressBtn.btnData as! String).lowercased().range(of: "signature") != nil {
                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControl.Event.touchUpInside)
                    }
                    imgPressBtn.layer.cornerRadius = 11
                    imgPressBtn.layer.masksToBounds = true
                    imgPressBtn.setTitleColor(UIColor.white, for: .normal)
                    imgPressBtn.setTitle("Change \(name)", for: .normal)
                    print(name)
                    if name == "logo" {
                        imgPressBtn.setTitle("Change seal", for: .normal)
                    }
                    imgPressBtn.backgroundColor = UIColor(red: 234/255, green: 60/255, blue: 87/255, alpha: 0.8)
                    yValue = yValue + 35 + 10
                }
            }
            
            contentScrollView.contentSize.height = yValue+30
            contentScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentScrollView.bounces = false
        }
            
        else {
            
            let selectedTempDict : NSDictionary =  Context.getInstance().getTemplateForId(self.cert.templateId!) as NSDictionary
            print(" show all \(selectedTempDict)")
             // setUpTextFields
            if let textFieldArray : NSArray = selectedTempDict.value(forKey: "textFields") as? NSArray {
                for aTextField in textFieldArray {
                    textInfoDict = aTextField as! NSDictionary
                    let name : String = textInfoDict.value(forKey: "name") as! String
                    let tField = storeTextFInstance[name] as! UITextField
                    let textField = CustomTextField(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30 - 35 , height: 35))
                    let customizeBtn = CustomUIButton(frame:CGRect(x:15+textField.frame.width , y:textField.frame.origin.y-1 , width : 35 , height: 35+2))
                    customizeBtn.btnData = name as AnyObject
                    customizeBtn.setBackgroundImage(#imageLiteral(resourceName: "customizeBtn"), for: .normal)
                    customizeBtn.addTarget(self, action: #selector(EditCertificateViewController.customizeTheTextField(_:)), for: UIControl.Event.touchUpInside)
                    
                    contentScrollView.addSubview(textField)
                    contentScrollView.addSubview(customizeBtn)
                    textField.delegate = self
                    textField.placeholder = tField.placeholder
                    textField.text = tField.text
                    textField.txtFData = name as AnyObject
                    textField.autocorrectionType = UITextAutocorrectionType.no
                    textField.returnKeyType = UIReturnKeyType.done
                    textField.textAlignment = .left
                    textField.textColor = UIColor.white
                    textField.backgroundColor = UIColor(red: 47/255, green: 53/255, blue: 75/255, alpha: 1)
                    textField.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                    if name == "date" {
                        let dateBtn = CustomUIButton(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30 , height: 35))
                        dateBtn.btnData = name as AnyObject
                        
                        dateBtn.addTarget(self, action: #selector(EditCertificateViewController.showDatePicker), for: UIControl.Event.touchUpInside)
                        contentScrollView.addSubview(dateBtn)
                        dateTF = textField
                    }
                    yValue = yValue + 30 + 10
                    storeEditTextFieldInstance[name] = textField
                }
                loadCustomizingView()
                customizingView.fontSizeTxtField.delegate = self
                customizingView.colorPicker.delegate = self
            }
            
            // setUpTextViews
            if let textViewArray : NSArray = selectedTempDict.value(forKey: "textViewFields") as? NSArray {
                for aTextView in textViewArray {
                    textViewInfoDict = aTextView as! NSDictionary
                    let name : String = textViewInfoDict.value(forKey: "name") as! String
                    let tView = storeTextVInstance[name] as! UITextView
                    let textView = CustomTextView(frame:CGRect(x:15 , y:yValue , width : contentScrollView.frame.width-30-35 , height: 35*3))
                    let customizeBtn = CustomUIButton(frame:CGRect(x:15+textView.frame.size.width , y:yValue-1 , width : 35 , height: 35+2))
                    customizeBtn.btnData = name as AnyObject
                    customizeBtn.setBackgroundImage(#imageLiteral(resourceName: "customizeBtn"), for: .normal)
                    customizeBtn.addTarget(self, action: #selector(EditCertificateViewController.customizeTheTextView(_:)), for: UIControl.Event.touchUpInside)
                    contentScrollView.addSubview(textView)
                    contentScrollView.addSubview(customizeBtn)
                    textView.delegate = self
                    textView.txtVData = name as AnyObject
                    textView.text = tView.text
                    textView.autocorrectionType = UITextAutocorrectionType.no
                    textView.returnKeyType = UIReturnKeyType.done
                    textView.textAlignment = .left
                    textView.textColor = UIColor.white
                    textView.backgroundColor = UIColor(red: 47/255, green: 53/255, blue: 75/255, alpha: 1)
                    yValue = yValue + 35*3 + 10
                    storeEditTextViewInstance[name] = textView
                }
            }
            
            // setUpImageViews
            
            if let imgViewArray : NSArray = selectedTempDict.value(forKey: "imageFields") as? NSArray {
                for aImgView in imgViewArray {
                   imgInfoDict = aImgView as! NSDictionary
                    let name : String = imgInfoDict.value(forKey: "name") as! String
                    let imgPressBtn = CustomUIButton(frame:CGRect(x:15 , y:yValue+10 , width : contentScrollView.frame.width-30 , height: 35))
//                    imgPressBtn.addTarget(self, action: #selector(TemplateVIewController.OpenGalleryForLogo(_:)), for: UIControlEvents.touchUpInside)
                    contentScrollView.addSubview(imgPressBtn)
                    imgPressBtn.btnData = name as AnyObject
                    if imgPressBtn.btnData as! String == "logo" {
                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                    }
//                    else if imgPressBtn.btnData as! String == "signature" {
//                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControlEvents.touchUpInside)
//                    }
                    if (imgPressBtn.btnData as! String).lowercased().range(of: "signature") != nil {
                        imgPressBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControl.Event.touchUpInside)
                    }
                    imgPressBtn.layer.cornerRadius = 11
                    imgPressBtn.layer.masksToBounds = true
                    imgPressBtn.setTitleColor(UIColor.white, for: .normal)
                    imgPressBtn.setTitle("Change \(name)", for: .normal)
                    if name == "logo" {
                        imgPressBtn.setTitle("Change Seal", for: .normal)
                    }
                    imgPressBtn.backgroundColor = UIColor(red: 234/255, green: 60/255, blue: 87/255, alpha: 0.8)
                    yValue = yValue + 35 + 10
                }
            }
            
            contentScrollView.contentSize.height = yValue+30
            contentScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentScrollView.bounces = false
        }
        // setUpTextFields
       
    }
    
    func updateAndBuildTf(txtField:AnyObject) {
        let dictionary: [String:AnyObject] = [
            "x" : (txtField as! DBTextField).x!,
            "y" : (txtField as! DBTextField).y!,
            "widthInPixels" : (txtField as! DBTextField).widthInPixels!,
            "heightInPixels" : (txtField as! DBTextField).heightInPixels!,
            "name" : (txtField as! DBTextField).templateName! as AnyObject ,
            "content" : (txtField as! DBTextField).content! as AnyObject,
            "fontColorHex" : (txtField as! DBTextField).fontColorHex! as AnyObject,
            "fontFace" : (txtField as! DBTextField).fontFace! as AnyObject,
            "fontFamily" : (txtField as! DBTextField).fontFamily! as AnyObject,
            "fontSize" : (txtField as! DBTextField).fontSize! as AnyObject ,
            "placeholder" : (txtField as! DBTextField).placeholder! as AnyObject ,
            ]
        buildTextField(tfDict: dictionary as NSDictionary)
    }
    
    func updateAndBuildTV(txtView:AnyObject) {
        let dictionary: [String:AnyObject] = [
            "x" : (txtView as! DBTextView).x as AnyObject,
            "y" : (txtView as! DBTextView).y as AnyObject,
            "widthInPixels" : (txtView as! DBTextView).widthInPixels as AnyObject,
            "heightInPixels" : (txtView as! DBTextView).heightInPixels as AnyObject,
            "name" : (txtView as! DBTextView).templateName! as AnyObject ,
            "content" : (txtView as! DBTextView).content! as AnyObject,
            "fontColorHex" : (txtView as! DBTextView).fontColorHex! as AnyObject,
            "fontFace" : (txtView as! DBTextView).fontFace! as AnyObject,
            "fontFamily" : (txtView as! DBTextView).fontFamily! as AnyObject,
            "fontSize" : (txtView as! DBTextView).fontSize as AnyObject ,
            //"placeholder" : (txtView as! DBTextView).placeholder! as AnyObject ,
        ]
        buildTextView(tVDict: dictionary as NSDictionary)
    }
    
    func fetchTextFieldData() {
        if let textFieldArray : NSArray = selectedTemplateData.value(forKey: "textFields") as? NSArray {
            for aTextField in textFieldArray {
                textInfoDict = aTextField as! NSDictionary
                buildTextField(tfDict: textInfoDict)
            }
        }
    }
    
    func fetchTextViewData() {
        if let textViewArray : NSArray = selectedTemplateData.value(forKey: "textViewFields") as? NSArray {
            for aTextView in textViewArray {
                textViewInfoDict = aTextView as! NSDictionary
                buildTextView(tVDict: textViewInfoDict)
            }
        }
    }
    
    func buildTextView(tVDict: NSDictionary) {
        let x = (tVDict.value(forKey: "x")!)
        let y = (tVDict.value(forKey: "y")!)
        let w = (tVDict.value(forKey: "widthInPixels")!)
        let h = (tVDict.value(forKey: "heightInPixels")!)
        
        let aTxtView = UITextView(frame: CGRect(x: CGFloat((x as AnyObject) .doubleValue),
                                                y: CGFloat((y as AnyObject) .doubleValue),
                                                width: CGFloat((w as AnyObject) .doubleValue),
                                                height: CGFloat((h as AnyObject) .doubleValue)))
        aTxtView.delegate = self
        containerView.addSubview(aTxtView)
        
        var fontFamily: String = tVDict.value(forKey: "fontFamily")as! String
        let fontFace: String = tVDict.value(forKey: "fontFace")as! String
        let fontColorHex: String = tVDict.value(forKey: "fontColorHex")as! String
         let placeHolder: String = tVDict.value(forKey: "content")as! String
//         let contentText: String = tVDict.value(forKey: "content")as! String
        
        let fontSize = tVDict.value(forKey: "fontSize") as! NSNumber
        aTxtView.isUserInteractionEnabled = false
        aTxtView.textAlignment = .center
       
        if selectedTemplateData.count == 0 {
            if placeHolder == "" {
                aTxtView.text = "Enter a description"
            } else {
                aTxtView.text = placeHolder
            }
        }
        
        else {
            if let text = storeTFAndTVTextDefaults.string(forKey: tVDict.value(forKey: "name") as! String) {
                aTxtView.text = text
            }
            else {
                if placeHolder == "" {
                    aTxtView.text = "Enter a description"
                } else {
                    aTxtView.text = placeHolder
                }
            }
        }

        
        if fontFace != "" {
            fontFamily = (fontFamily as String)+"-"+(fontFace as String)
            print(fontFamily)
            for family in UIFont.familyNames {
                for name in UIFont.fontNames(forFamilyName: family) {
                    if fontFamily == name{
                        aTxtView.font = UIFont(name: fontFamily as String, size: CGFloat((fontSize as AnyObject) .floatValue))
                    }
                    else {
                        aTxtView.font = UIFont(name: "Roboto-Black", size: CGFloat((fontSize as AnyObject) .floatValue))
                    }
                }
            }
        }
        
        // aTxtView.placeholder = placeHolder as String
//        aTxtView.font = aTxtView.font!.withSize(CGFloat((fontSize as AnyObject) .floatValue))
        
        let color = hexStringToUIColor(fontColorHex as String)
        if fontColorHex == "#000000"{
            aTxtView.textColor = UIColor.black
        }
        else {
            aTxtView.textColor = color
        }
       
      
        print(aTxtView.text)
        // aTxtView.borderStyle = UITextBorderStyle.none
        aTxtView.autocorrectionType = UITextAutocorrectionType.no
        aTxtView.returnKeyType = UIReturnKeyType.done
        aTxtView.backgroundColor = UIColor.clear
        storeTextVInstance[tVDict.value(forKey: "name")!] = aTxtView
    }
    
    
    func buildTextField(tfDict:NSDictionary){
        let x = (tfDict.value(forKey: "x")!)
        let y = (tfDict.value(forKey: "y")!)
        let w = (tfDict.value(forKey: "widthInPixels")!)
        let h = (tfDict.value(forKey: "heightInPixels")!)
        
        let aTxtfield = UITextField(frame: CGRect(x: CGFloat((x as AnyObject) .doubleValue),
                                                  y: CGFloat((y as AnyObject) .doubleValue),
                                                  width: CGFloat((w as AnyObject) .doubleValue),
                                                  height: CGFloat((h as AnyObject) .doubleValue)))
        
        var fontFamily: String = tfDict.value(forKey: "fontFamily")as! String
        let fontFace: String = tfDict.value(forKey: "fontFace")as! String
        var fontColorHex: String = tfDict.value(forKey: "fontColorHex")as! String
        let placeHolder: String = tfDict.value(forKey: "placeholder")as! String
        let contentText: String = tfDict.value(forKey: "content")as! String
        let fontSize = tfDict.value(forKey: "fontSize") as! NSNumber
        
        
        if fontFace != "" {
            fontFamily = (fontFamily as String)+"-"+(fontFace as String)
            print(fontFamily)
        }
        
        if fontColorHex == "#000000"{
            fontColorHex = "#090000"
        }
        
        aTxtfield.placeholder = placeHolder as String
        aTxtfield.font = UIFont(name: fontFamily as String, size: CGFloat((fontSize as AnyObject) .floatValue))
        aTxtfield.font = aTxtfield.font!.withSize(CGFloat((fontSize as AnyObject) .floatValue))

        let color = hexStringToUIColor(fontColorHex as String)
        print(fontColorHex)
       
        
        if selectedTemplateData.count == 0 {
            aTxtfield.text = contentText
        }
        else {
            if let text = storeTFAndTVTextDefaults.string(forKey: tfDict.value(forKey: "name") as! String) {
                aTxtfield.text = text
            }
            else {
                aTxtfield.text = contentText
            }
        }
        aTxtfield.textColor = color
        aTxtfield.borderStyle = UITextField.BorderStyle.none
        aTxtfield.autocorrectionType = UITextAutocorrectionType.no
        aTxtfield.keyboardType = UIKeyboardType.default
        aTxtfield.returnKeyType = UIReturnKeyType.done
        aTxtfield.textAlignment = .center
        aTxtfield.isUserInteractionEnabled = true
        
        print("Frame before setting delegate \(aTxtfield.frame)")
        aTxtfield.delegate = self
        aTxtfield.isUserInteractionEnabled = false
        containerView.addSubview(aTxtfield)
        print("Frame before after adding subview \(aTxtfield.frame)")
        
        storeTextFInstance[tfDict.value(forKey: "name")!] = aTxtfield
    }
    
    
    func fetchImageFieldsData() {
        if let imgFieldsArray : NSArray = selectedTemplateData.value(forKey: "imageFields") as? NSArray {
            for value in imgFieldsArray {
                imgInfoDict = value as! NSDictionary
//                let logoImgUrl : NSString = imgInfoDict.value(forKey: "Url") as! NSString
//                let imageURL = URL(string: logoImgUrl as String)
//                let data:Data?  = try? Data(contentsOf: imageURL!)
//                self.image = UIImage(data: data!)
                
                let imgStr : NSString = imgInfoDict.value(forKey: "image") as! NSString
                self.image = UIImage.init(named: imgStr as String)
                guard let _ = self.image else {
                    return
                }
                let wx = (self.imgInfoDict.value(forKey: "x")!)
                let wy = (self.imgInfoDict.value(forKey: "y")!)
                let ww = (self.imgInfoDict.value(forKey: "widthInPixels")!)
                let wh = (self.imgInfoDict.value(forKey: "heightInPixels")!)
                
                
                let x1 : CGFloat = CGFloat((wx as AnyObject) .doubleValue)
                let y1 : CGFloat = CGFloat((wy as AnyObject) .doubleValue)
                let w1 : CGFloat = CGFloat((ww as AnyObject) .doubleValue)
                let h1 : CGFloat = CGFloat((wh as AnyObject) .doubleValue)
                
                let imgView:UIImageView = UIImageView(frame: CGRect(x: x1, y: y1, width: w1, height: h1))
                imgView.image = self.image
                containerView.addSubview(imgView)
                let editImgBtn = CustomUIButton(frame: CGRect(x: imgView.frame.origin.x, y: imgView.frame.origin.y, width: imgView.frame.size.width, height: imgView.frame.size.height))

                containerView.addSubview(editImgBtn)
                editImgBtn.btnData = imgInfoDict.value(forKey: "name") as! NSString

                if editImgBtn.btnData as! String == "logo" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                }
                
                if (editImgBtn.btnData as! String).lowercased().range(of: "signature") != nil {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControl.Event.touchUpInside)
                }

                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                storeImgVInstance[imgInfoDict.value(forKey: "name")!] = imgView
                storeCreateImgPicker[imgInfoDict.value(forKey: "name")!] = imgPicker
            }
        }
    }
    
    func updateView(_cert:DBCertificate) {
        cert = _cert
        loadBgImgView(bgImageUrlString: _cert.templateBgImageUrl! as NSString, bgImageWidth: _cert.templateWidthInPixels!, bgImageHeight: _cert.templateHeightInPixels!)
    }

    
    // surya :- open gallery for selecting logo image
    func OpenGalleryForLogo(_ sender:String) {
        storeCurrentImgView = sender
        let imgPicker = storeCreateImgPicker[sender] as! UIImagePickerController
        imgPicker.allowsEditing = false
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated:true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imgView = storeImgVInstance[storeCurrentImgView] as! UIImageView
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        {
            imgView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // surya :- add image to gallery
    func writeImageToGallery(_ savedName:String) -> Data {
        let sampleImage = UIImage.renderUIViewToImage(containerView)
        let imgData : Data = sampleImage.pngData()!
        /*
        let date :Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd_yyyy'_'HH:mm:ss"
        let imageName = "/\(savedName)_\(dateFormatter.string(from: date)).png"
        var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDirectoryPath += imageName
        
        try? imgData.write(to: URL(fileURLWithPath: documentsDirectoryPath), options: [.atomic])
        if Context.getInstance().isProVersion() == true {
          UIImageWriteToSavedPhotosAlbum(sampleImage, nil, nil, nil);
        }
         */
        return imgData
    }
    
/*    // Surya :- ask Save befor save , then save to Core Data or update to Core Data and save to gallery
    func askTitleAndthenSave () {
        var titleTextField: UITextField?
        let alertController = UIAlertController(
            title: "Title",
            message: "Please enter a title to save your certificate",
            preferredStyle: UIAlertControllerStyle.alert)
        let saveAction = UIAlertAction(
        title: "Save", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let title = titleTextField?.text {
                if title.characters.count > 3 {
                    if self.cert == nil {
                        self.cert = NSEntityDescription.insertNewObject(forEntityName: "DBCertificate", into: self.managedObjContext) as! DBCertificate
                        self.storeCertificateDatatoDB(self.cert)
                        self.storeImgFieldAndTfAndTviewData(self.cert)
                    }
                    else {
                        self.updateCertificateDatatoDB(self.cert)
                        self.updateImgfTfAndTVData(self.cert)
                    }
                    
                    let imgData : Data = self.writeImageToGallery(title)
                    self.cert.setValue(imgData, forKey: "image")
                    self.cert.setValue(title, forKey: "certificateTitle")
                    do {
                        try self.managedObjContext.save()
                    }catch {
                        print(error.localizedDescription)
                    }
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let tempVC = storyBoard.instantiateViewController(withIdentifier: "CertificatesTableViewController") as! CertificatesTableViewController
                    self.navigationController?.pushViewController(tempVC, animated: true)
                }
                else {
                    titleTextField?.becomeFirstResponder()
                    let alertController = UIAlertController(
                        title: " 🙁 Error. Please Resave.",
                        message: " Name should contain maximum 3 letters and should not be start with space. ",
                        preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(
                    title: "OK", style: UIAlertActionStyle.default) {
                        (action) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                titleTextField?.becomeFirstResponder()
            }
        }
        alertController.addAction(saveAction)
        
        let noAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
//            tableView.scrollToTop(animated: true)
            self.contentScrollView.scrollsToTop = true
        }
        alertController.addTextField {
            (txtSomename) -> Void in
            titleTextField = txtSomename
            titleTextField!.placeholder = "<Your title here>"
            if self.cert != nil {
                titleTextField!.text = self.cert.certificateTitle
            }
        }
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    } */
    
    @objc func customizeTheTextField(_ sender: CustomUIButton) {
        hideKeyboard()
        storeSelectedEditTFData = sender.btnData as! String
        customizingView.selectedCustomizeableTFOrTV = "TextFieldSelected"
        customizeableField = storeTextFInstance[storeSelectedEditTFData] as! UITextField
        fontSize = (customizeableField.font?.pointSize)!
        customizingView.fontStepper.value = Double(fontSize)
        customizingView.fontSizeTxtField.text = "\(fontSize)"
        customizingView.txtColorHexCode.text = hexStringFromUIColor(customizeableField.textColor!)
        selectedFontName = (customizeableField.font?.fontName)!
        selectedColor = customizeableField.textColor!
        showCustomizingView()
    }
    
    @objc func customizeTheTextView(_ sender: CustomUIButton) {
        hideKeyboard()
        storeSelectedEditTVData = sender.btnData as! String
        customizingView.selectedCustomizeableTFOrTV = "TextViewSelected"
        customizeableView = storeTextVInstance[storeSelectedEditTVData] as! UITextView
        fontSize = (customizeableView.font?.pointSize)!
        customizingView.fontStepper.value = Double(fontSize)
        customizingView.fontSizeTxtField.text = "\(fontSize)"
        customizingView.txtColorHexCode.text = hexStringFromUIColor(customizeableView.textColor!)
        selectedFontName = (customizeableView.font?.fontName)!
        selectedColor = customizeableView.textColor!
        showCustomizingView()
    }
    
    func showCustomizingView() {
        customizingView.isHidden = false
        self.view.bringSubviewToFront(customizingView)
        customizingView.colorPicker.setViewColor(selectedColor)
    }
    
    func hideCustomizingView(_ customizingView : CustomizingView) {
        customizingView.isHidden = true
        self.view.sendSubviewToBack(customizingView)
    }
    
    func loadCustomizingView(){
        customizingView = (Bundle.main.loadNibNamed("CustomizingView", owner: self, options: nil)?.first as? CustomizingView)!
        customizingView.frame = contentScrollView.frame
        self.view.addSubview(customizingView)
        self.view.bringSubviewToFront(customizingView)
        hideCustomizingView(customizingView)
        customizingView.fontSizeTxtField.addTarget(self, action: #selector(EditCertificateViewController.changeFontSizeTF(_:)), for: UIControl.Event.editingChanged)
        customizingView.fontStepper.addTarget(self, action: #selector(EditCertificateViewController.changeFontSize(_:)), for: UIControl.Event.valueChanged)
        setFontListArray()
    }
    
    @objc func changeFontSize(_ sender: UIStepper) {
        let fontSize = CGFloat(sender.value)
        customizingView.fontSizeTxtField.text = "\(fontSize)"
        setTextFieldFont(fontSize)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let nibName = UINib(nibName: "FontCell", bundle:nil)
        customizingView.fontListTableView.register(nibName, forCellReuseIdentifier: "CellID")

        let  cell: FontCell = customizingView.fontListTableView.dequeueReusableCell(withIdentifier: "CellID") as! FontCell
       
        cell.textLabel?.text = fontArray.object(at: indexPath.row) as? String
        if let dotRange = cell.textLabel?.text!.range(of: ".") {            cell.textLabel?.text!.removeSubrange(dotRange.lowerBound..<(cell.textLabel?.text!.endIndex)!)
        }

//        let selectedIndexPath = customizingView.fontListTableView.indexPathForSelectedRow
//        print(selectedIndexPath ?? "none")
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name:(cell.textLabel?.text)!, size:22)
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFontName = fontArray.object(at: indexPath.row) as! String
       let  cell = customizingView.fontListTableView.cellForRow(at: indexPath) as! FontCell
        cell.contentView.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.2823529412, blue: 0.3882352941, alpha: 1)
        if let dotRange = selectedFontName.range(of: ".") {
            selectedFontName.removeSubrange(dotRange.lowerBound..<selectedFontName.endIndex)
        }
        
        if customizingView.selectedCustomizeableTFOrTV == "TextFieldSelected" {
            customizeableField.font = UIFont(name: selectedFontName, size: fontSize)
        }
        else if customizingView.selectedCustomizeableTFOrTV == "TextViewSelected" {
            customizeableView.font = UIFont(name: selectedFontName, size: fontSize)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = customizingView.fontListTableView.cellForRow(at: indexPath) as? FontCell {
            cell.contentView.backgroundColor = UIColor.clear
        }
    }
    
    func setFontListArray(){
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            fontArray = dict["UIAppFonts"]! as! NSMutableArray
           customizingView.fontListTableView.delegate = self
           customizingView.fontListTableView.dataSource = self
        }
    }
    
    func setTextColor(_ pView:SwiftHSVColorPicker){
        if customizingView.selectedCustomizeableTFOrTV == "TextFieldSelected" {
            customizeableField.textColor = pView.color
            selectedColor = customizeableField.textColor!
        }
            
        else if customizingView.selectedCustomizeableTFOrTV == "TextViewSelected" {
            customizeableView.textColor = pView.color
            selectedColor = customizeableView.textColor!
        }
         setHexString(pView.color)
    }
    
    func setHexString(_ color:UIColor){
        var txtColorHex = hexStringFromUIColor(color)
        // changing 7 to 9
        if txtColorHex.count > 7 {
            let index = txtColorHex.index(txtColorHex.startIndex, offsetBy: 7)
            txtColorHex = txtColorHex.substring(to: index)  // Hello
        }
        customizingView.txtColorHexCode.text = txtColorHex
    }
    
    @objc func OpenAndAddSeal(_ sender:CustomUIButton!) {
        hideKeyboard()
        let sealActionSheetController = UIAlertController()
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            sealActionSheetController.dismiss(animated: true, completion: nil)
        }
        sealActionSheetController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Upload from gallery", style: .default) { action -> Void in
            self.OpenGalleryForLogo(sender.btnData as! String)
        }
        sealActionSheetController.addAction(takePictureAction)
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose from existing", style: .default) { action -> Void in
            self.view.bringSubviewToFront(self.blurEffectView)
            self.blurEffectView.isHidden = false
            self.showChooseSealView()
        }
        sealActionSheetController.addAction(choosePictureAction)
        
        if let popoverController = sealActionSheetController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.present(sealActionSheetController, animated: true, completion: nil)
    }
    
    @objc func uploadORwriteSignature(_ sender:CustomUIButton!) {
        hideKeyboard()
        storeSignImgDat = sender.btnData as! String
        NSLog("image data \(storeSignImgDat)")
        let sealActionSheetController = UIAlertController()
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            sealActionSheetController.dismiss(animated: true, completion: nil)
        }
        sealActionSheetController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Upload from gallery", style: .default) { action -> Void in
            self.OpenGalleryForLogo(sender.btnData as! String)
        }
        sealActionSheetController.addAction(takePictureAction)
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Sign in", style: .default) { action -> Void in
            self.view.bringSubviewToFront(self.blurEffectView)
            self.blurEffectView.isHidden = false
            self.showSignInView()
        }
        sealActionSheetController.addAction(choosePictureAction)
        if let popoverController = sealActionSheetController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.present(sealActionSheetController, animated: true, completion: nil)
    }
    
    func drawingSignature () {
    }
    
    func image (_ signature: UIImage?) -> () {
        signImg = signature!
    }
    
    func showSignInView() {
        self.view.bringSubviewToFront(signView)
        self.view.bringSubviewToFront(signAndSealBtnHolderStackView)
        signView.isHidden = false
        signAndSealBtnHolderStackView.isHidden = false
        uploadSealContainerView.isHidden = true
    }

    func hideChooseSealAndSignVIewView() {
        signView.isHidden = true
        signAndSealBtnHolderStackView.isHidden = true
        uploadSealContainerView.isHidden = true
    }
    
    func showChooseSealView() {
        self.view.bringSubviewToFront(uploadSealContainerView)
        self.view.bringSubviewToFront(signAndSealBtnHolderStackView)
        signView.isHidden = true
        signAndSealBtnHolderStackView.isHidden = false
        uploadSealContainerView.isHidden = false
    }
    
    @IBAction func cacelSignInORChooseSealView(_ sender: UIButton) {
        self.blurEffectView.isHidden = true
        signView.clear()
        hideChooseSealAndSignVIewView()
    }
    
    @IBAction func clearTheSignSection(_ sender: UIButton) {
      signView.clear()
    }
    
    @IBAction func saveTheSignOrSeal(_ sender: UIButton) {
        if signView.isHidden == true {
            self.blurEffectView.isHidden = true
            let imgView = storeImgVInstance["logo"] as! UIImageView
            imgView.image = selcetedSealImage.image
            imgView.contentMode = .scaleAspectFit

            hideChooseSealAndSignVIewView()
        }
            
        else if uploadSealContainerView.isHidden == true {
            self.blurEffectView.isHidden = true
            let imgView = storeImgVInstance[storeSignImgDat] as! UIImageView
            NSLog("show image \(signImg)")
            imgView.image = signImg
            hideChooseSealAndSignVIewView()
        }
        signView.clear()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(sealsArray.count)
        return sealsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadSealCellID", for: indexPath)
        let cellImgV = UIImageView(frame: CGRect(x: cell.contentView.frame.origin.x, y: cell.contentView.frame.origin.y, width: cell.contentView.frame.size.width, height: cell.contentView.frame.size.height))
        cellImgV.image = UIImage.init(named: sealsArray.object(at: indexPath.row) as! String)
        cellImgV.contentMode = .scaleToFill
        cell.contentView.addSubview(cellImgV)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selcetedSealImage.image = UIImage.init(named: sealsArray[indexPath.row] as! String)
    }
    
    // MARK: Adding image to album
    func createPhotoOnAlbum(photo: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                // Album change request has failed
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                // Photo Placeholder is nil
                return
            }
            albumChangeRequest.addAssets([photoPlaceholder] as NSArray)
        }, completionHandler: { success, error in
            if success {
                // Saved successfully!
            }
            else if error != nil {
                // Save photo failed with error
            }
            else {
                // Save photo failed with no error
            }
        })
    }

    
    
    
}
