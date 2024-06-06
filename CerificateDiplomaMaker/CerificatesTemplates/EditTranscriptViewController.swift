//
//  EditTranscriptViewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 1/3/17.
//  Copyright © 2017 Mobiona. All rights reserved.
//

import UIKit
import CoreData
import Photos


class GradeTabeleViewCell : UITableViewCell {
    
    @IBOutlet weak var courseNumberTF: UITextField!
    @IBOutlet weak var courseNameTF: UITextField!
    @IBOutlet weak var gradeTF: UITextField!
    @IBOutlet weak var creditHourTF: UITextField!
}

class customSegBtn:UIButton {
    func btnISSelecetd(){
        self.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0, blue: 0.231372549, alpha: 1), for: .normal)
    }
    func btnISDeselected(){
        self.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
}

class EditTranscriptViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, SHFSignatureProtocol {

    @IBOutlet weak var gradeTableView: UITableView!
    @IBOutlet weak var editTranscriptScroll: UIScrollView!
    var saveItem = UIBarButtonItem()

    var editContainerView : UIView!
    var gradeArray = NSMutableArray()
    
    @IBOutlet weak var firstSegBtn: customSegBtn!
    @IBOutlet weak var secondSegBtn: customSegBtn!
    @IBOutlet weak var thirdSegBtn: customSegBtn!
    @IBOutlet weak var addAGradeCellBtn: UIButton!
    @IBOutlet weak var descriptionTF: UITextView!
    @IBOutlet weak var segBtnHolderView: UIView!
    
    @IBOutlet weak var termTF: UITextField!
    @IBOutlet weak var currentEHRSTF: UITextField!
    @IBOutlet weak var qptsTF: UITextField!
    @IBOutlet weak var gpaTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    
    @IBOutlet weak var addLogoBtn: UIButton!
    @IBOutlet weak var addSignBtn: UIButton!
    @IBOutlet weak var addBarcodeBtn: UIButton!
    
    @IBOutlet weak var nameOfCandidateTF: UITextField!
    @IBOutlet weak var nameOfInstituteTF: UITextField!
    @IBOutlet weak var serialNumberTF: UITextField!
    
    var selectedTranscriptData = NSDictionary()
    let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext


    let albumName = "Diploma"
//    var cert : DBCertificate!
    
    var transcript : DBTranscript!
    
    var image : UIImage!
    var scrollView: UIScrollView!
    var containerView : UIView!
    var transcriptImageView: UIImageView!
    
    var savedFrame = CGRect()
    var saveContentOffset = CGPoint()
    var storeYConstraintOfContentSV = CGFloat()
    
    var textInfoDict = NSDictionary()
    var textViewInfoDict = NSDictionary()
    var imgInfoDict  = NSDictionary()
    
    var storeTextFInstance: NSMutableDictionary! = [:]
    var storeImgVInstance = NSMutableDictionary()
    var storeTextVInstance = NSMutableDictionary()
    
    var storeCreateImgPicker = NSMutableDictionary()
    
    var storeTFAndTVTextDefaultsForTranscript = UserDefaults.standard
    
    var lastContentOffset = CGFloat()
    
    var logoPicker = UIImagePickerController()
    var signPicker = UIImagePickerController()
    var barcodePicker = UIImagePickerController()
    
    var gradeCellCount = 0
    var isKeyboardVisible = false
    var signImg = UIImage()
    var storeSignImgDat = String()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneDatePicker: UIButton!
    @IBOutlet weak var datePickerBackView: UIView!
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var signView: SHFSignatureView!
    @IBOutlet weak var signAndSealBtnHolderStackView: UIStackView!
    
    var storeCurrentImgView = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradeTableView.delegate = self
        gradeTableView.dataSource = self
        addAGradeCellBtn.isHidden = true
        signView.delegate = self
        
        hideDatePicker()
        
        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(EditTranscriptViewController.Cancel))
        
        navigationItem.leftBarButtonItem = backItem
        
        saveItem = UIBarButtonItem(image:UIImage(named: "nav_save_btn.png"), landscapeImagePhone: UIImage(named: "nav_save_btn.png"), style: .plain, target: self, action: #selector(EditTranscriptViewController.Save))
        saveItem.tintColor = UIColor.white
        navigationItem.setRightBarButton(saveItem, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if selectedTranscriptData.count != 0 {
            loadBgImgView(bgImageUrlString: selectedTranscriptData.value(forKey: "bgImageName") as! NSString, bgImageWidth: self.selectedTranscriptData.value(forKey: "widthInPixels")! as! NSNumber, bgImageHeight: self.selectedTranscriptData.value(forKey: "heightInPixels")! as! NSNumber)
        }
        editTranscriptScroll.delegate = self
        logoPicker.delegate = self
        signPicker.delegate = self
        barcodePicker.delegate = self
        
         editTranscriptScroll.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
       
    }
    
    @IBAction func clearTheSign(_ sender: UIButton) {
        signView.clear()
    }
    @IBAction func cancelSign(_ sender: UIButton) {
        self.blurEffectView.isHidden = true
        signView.clear()
        hideChooseSealAndSignVIewView()
    }
    @IBAction func saveSign(_ sender: UIButton) {
        self.blurEffectView.isHidden = true
        let imgView = storeImgVInstance[storeSignImgDat] as! UIImageView
        NSLog("show image \(signImg)")
        imgView.image = signImg
        hideChooseSealAndSignVIewView()
        signView.clear()
    }
    func hideChooseSealAndSignVIewView() {
        signView.isHidden = true
        signAndSealBtnHolderStackView.isHidden = true
        //uploadSealContainerView.isHidden = true
    }
    
    func drawingSignature() {
        
    }
    func image(_ signature: UIImage?) {
        signImg = signature!
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

        
//        if transcript != nil {
//            _ = navigationController?.popViewController(animated: true)
//        }
//        
//        else {
//            _ = navigationController?.popToViewController(self.navigationController!.viewControllers[1] as! TranscriptTableViewController , animated: true)
//        }
    }
    
    @objc func Save() {
        hideKeyboard()
        // Check if Pro version
        if Context.getInstance().isProVersion() == false {
            // Fetch Data from Certificate
            let fetchRequest2: NSFetchRequest<DBTranscript> = DBTranscript.fetchRequest()
            // Edit the entity name as appropriate.
            let entity2 = NSEntityDescription.entity(forEntityName: "DBTranscript", in: self.managedObjContext)
            fetchRequest2.entity = entity2
            var certCount:Int = 0
            do {
                let fetchObj2 = try self.managedObjContext.fetch(fetchRequest2)
                certCount = fetchObj2.count
            } catch{
                print(error.localizedDescription)
            }
            if certCount > Int(MAX_ALLOWED_CERTS_IN_FREE_VERSION) {
                (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)
                return
            }
        }
//        let sizeOfContent = templateImageView.frame.size.height + scrollView.frame.origin.y+10
//        scrollView.contentSize.height = sizeOfContent
//        scrollView.contentSize.width = templateImageView.bounds.size.width
//        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let defaults = UserDefaults.standard
        defaults.set("Transcript", forKey: "Name")
        defaults.set(serialNumberTF.text, forKey: "serialNumberTF")
        defaults.set(nameOfInstituteTF.text, forKey: "collegeNameTF")
        defaults.set(nameOfCandidateTF.text, forKey: "candidateNameTF")
        defaults.set(termTF.text, forKey: "termTF")
        defaults.set(currentEHRSTF.text, forKey: "currentEHRSTF")
        defaults.set(qptsTF.text, forKey: "qptsTF")
        defaults.set(gpaTF.text, forKey: "gpaTF")
        defaults.set(dateTF.text, forKey: "dateTF")
        defaults.set(descriptionTF.text, forKey: "descriptionTV")
        
        saveOrUpdateTheFileInDB()
        

    }
    
    func saveOrUpdateTheFileInDB() {
        if self.transcript == nil {
            self.transcript = NSEntityDescription.insertNewObject(forEntityName: "DBTranscript", into: self.managedObjContext) as! DBTranscript
            self.storeTranscriptDatatoDB(self.transcript)
            self.storeImgFieldAndTfAndTviewData(self.transcript)
        }
        else {
            self.updateTranscriptDatatoDB(self.transcript)
            self.updateImgfTfAndTVData(self.transcript)
        }
        
        let date :Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd_yyyy'_'HH:mm:ss"
        var savedName = ""
        
        let tField = storeTextFInstance["candidateName"] as! UITextField
        savedName = tField.text!
        
        let transTitle = "\(savedName) \(dateFormatter.string(from: date))"
        
        //let imgData : Data = self.writeImageToGallery(transTitle)
        //self.transcript.setValue(imgData, forKey: "image")
        
        let sampleImage = UIImage.renderUIViewToImage(containerView)
        let sampleThumbnailImage = Context.getInstance().resize(sampleImage, to: CGSize(width: 300, height: 350))
        let imgData : Data = sampleImage.pngData()!
        let imgThumbnailData : Data = sampleThumbnailImage!.pngData()!
        let fileName: String = Context.getInstance().getUniqueName(withPrefix: "Transcript", withSuffix: ".png")
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
        
        self.transcript.setValue(imgData, forKey: "image")
        self.transcript.setValue(fileName, forKey: "imageFilename")
        self.transcript.setValue(fileThumbnailName, forKey: "imageThumbFilename")
        self.transcript.setValue(transTitle, forKey: "transcriptTitle")
        
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
        let tempVC = storyBoard.instantiateViewController(withIdentifier: "TranscriptTableViewController") as! TranscriptTableViewController
        self.navigationController?.pushViewController(tempVC, animated: true)
    }
    
    
    func updateView(_trans:DBTranscript) {
        transcript = _trans
        loadBgImgView(bgImageUrlString: _trans.transcriptBgImageUrl! as NSString, bgImageWidth: _trans.transcriptWidthInPixels!, bgImageHeight: _trans.transcriptHeightInPixels!)
    }
    
    func writeImageToGallery(_ savedName:String) -> Data {
        let sampleImage = UIImage.renderUIViewToImage(containerView)
        let date :Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd_yyyy'_'HH:mm:ss"
        let imageName = "/\(savedName)_\(dateFormatter.string(from: date)).png"
        var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDirectoryPath += imageName
        let imgData : Data = sampleImage.pngData()!
        try? imgData.write(to: URL(fileURLWithPath: documentsDirectoryPath), options: [.atomic])
        if Context.getInstance().isProVersion() == true {
            UIImageWriteToSavedPhotosAlbum(sampleImage, nil, nil, nil);
        }
        return imgData
    }
    
    func storeTranscriptDatatoDB(_ transcript: DBTranscript) {
        let newTranscriptObject = transcript
        
        NSLog("data....\(selectedTranscriptData)")
        
        newTranscriptObject.setValue(Date(), forKey: "dateCreated")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "templateId"), forKey: "transcriptId")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "organization"), forKey: "organization")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "bgImageName"), forKey: "transcriptBgImageUrl")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "widthInPixels"), forKey: "transcriptWidthInPixels")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "heightInPixels"), forKey: "transcriptHeightInPixels")
        newTranscriptObject.setValue(selectedTranscriptData.value(forKey: "name"), forKey: "transcriptName")
        
    }
    
    
    func updateTranscriptDatatoDB(_ trans: DBTranscript) {
        let newTranscriptObject = trans
        newTranscriptObject.setValue(Date(), forKey: "dateCreated")
        newTranscriptObject.setValue(trans.transcriptId, forKey: "transcriptId")
        newTranscriptObject.setValue(trans.organization, forKey: "organization")
        newTranscriptObject.setValue(trans.transcriptBgImageUrl, forKey: "transcriptBgImageUrl")
        newTranscriptObject.setValue(trans.transcriptWidthInPixels, forKey: "transcriptWidthInPixels")
        newTranscriptObject.setValue(trans.transcriptHeightInPixels, forKey: "transcriptHeightInPixels")
        newTranscriptObject.setValue(trans.transcriptName, forKey: "transcriptName")
    }
    
    
    func updateImgfTfAndTVData(_ trans: DBTranscript) {
        let newTranscriptObject = trans
        for txtField in (trans.textFieldsTrans!.allObjects){
            let name: String = (txtField as! DBTextField).templateName!
            passTFData(txtField as! DBTextField, txtField: storeTextFInstance[name] as! UITextField)
            let tF = storeTextFInstance[name] as! UITextField
            storeTFAndTVTextDefaultsForTranscript.set(tF.text, forKey: name as String)
            (txtField as! DBTextField).setValue(name, forKey: "templateName")
            newTranscriptObject.addToTextFieldsTrans(txtField as! DBTextField)
            if tF.text == "" {
                tF.placeholder = ""
            }
        }
        
        for imgField in (trans.imageFieldsTrans?.allObjects)!  {
            let name : String = (imgField as! DBImageField).templateName!
            let imgView = storeImgVInstance[name] as! UIImageView
            passIMGFieldData(imgField as! DBImageField, imgView: imgView)
            (imgField as! DBImageField).setValue(name, forKey: "templateName")
            newTranscriptObject.addToImageFieldsTrans(imgField as! DBImageField)
        }
        
        for textView in (trans.textViewsTrans?.allObjects)!  {
            let name : String = (textView as! DBTextView).templateName!
            passTVData(textView as! DBTextView, txtView: storeTextVInstance[name] as! UITextView)
            let tV = storeTextVInstance[name] as! UITextView
            storeTFAndTVTextDefaultsForTranscript.set(tV.text, forKey: name as String)
            (textView as! DBTextView).setValue(name, forKey: "templateName")
            newTranscriptObject.addToTextViewsTrans(textView as! DBTextView)
            if tV.text == "Enter a description" {
                
                tV.text = ""
            }
        }
    }

    
    func storeImgFieldAndTfAndTviewData(_ transcript: DBTranscript) {
        let newTranscriptObject = transcript
        
        // store tF Data
        if let textFieldArray : NSArray = selectedTranscriptData.value(forKey: "textFields") as? NSArray {
            for value in textFieldArray {
                let newTextFieldObject = NSEntityDescription.insertNewObject(forEntityName: "DBTextField", into: managedObjContext) as! DBTextField
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let tField = storeTextFInstance[name] as! UITextField
                
                passTFData(newTextFieldObject, txtField: tField)
                newTextFieldObject.setValue(name, forKey: "templateName")
//                newTranscriptObject.addToTextFields(newTextFieldObject)
                newTranscriptObject.addToTextFieldsTrans(newTextFieldObject)
                storeTFAndTVTextDefaultsForTranscript.set(tField.text, forKey: name as String)
                // if the user want to write in certificate remove place holder text  to nil befor saving
                if tField.text == "" {
                    tField.placeholder = ""
                }
            }
        }
        
        
        // store imgF Data
        if let imgFieldsArray : NSArray = selectedTranscriptData.value(forKey: "imageFields") as? NSArray {
            for value in imgFieldsArray {
                let newImgFieldObject = NSEntityDescription.insertNewObject(forEntityName: "DBImageField", into: managedObjContext) as! DBImageField
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let imgView = storeImgVInstance[name] as! UIImageView
                passIMGFieldData(newImgFieldObject, imgView: imgView)
                newImgFieldObject.setValue(name, forKey: "templateName")
                newTranscriptObject.addToImageFieldsTrans(newImgFieldObject)
            }
        }
        // store textView Data
        if let textViewArray : NSArray = selectedTranscriptData.value(forKey: "textViewFields") as? NSArray {
            for value in textViewArray {
                let newTextViewObject = NSEntityDescription.insertNewObject(forEntityName: "DBTextView", into: managedObjContext) as! DBTextView
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let tView = storeTextVInstance[name] as! UITextView
                passTVData(newTextViewObject, txtView: tView)
                newTextViewObject.setValue(name, forKey: "templateName")
                newTranscriptObject.addToTextViewsTrans(newTextViewObject)
                storeTFAndTVTextDefaultsForTranscript.set(tView.text, forKey: name as String)
                if tView.text == "Enter a description" {
                    
                    tView.text = ""
                }
            }
        }
    }
    
    func passTFData(_ dbTf: DBTextField , txtField : UITextField) {
        let fontFace = retriveFontFace(txtField)
        print(txtField.placeholder!)
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
    
    
    func passIMGFieldData(_ dbIf:DBImageField , imgView : UIImageView) {
        dbIf.setValue(imgView.frame.size.height, forKey: "heightInPixels")
        //let imgData : Data? = UIImageJPEGRepresentation(imgView.image!,1.0)
        let imgData : Data? = imgView.image!.pngData()
        dbIf.setValue(imgData, forKey: "image")
        dbIf.setValue(imgView.frame.size.width, forKey: "widthInPixels")
        dbIf.setValue(imgView.frame.origin.x, forKey: "x")
        dbIf.setValue(imgView.frame.origin.y, forKey: "y")
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if isKeyboardVisible == true {
                dateTF.resignFirstResponder()
                isKeyboardVisible = false
                self.view.bringSubviewToFront(datePickerBackView)
                self.view.bringSubviewToFront(doneDatePicker)
                self.view.bringSubviewToFront(datePicker)
                datePickerBackView.isHidden = false
                doneDatePicker.isHidden = false
                datePicker.isHidden = false
                return
            }
            if self.view.frame.origin.y >= 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                //self.view.frame.origin.y += keyboardSize.height
                self.view.frame.origin.y = 0
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpDelegate()
    }
    
    func setUpDelegate() {
        
        termTF.delegate = self
        currentEHRSTF.delegate = self
        qptsTF.delegate = self
        gpaTF.delegate = self
        dateTF.delegate = self
        
        nameOfCandidateTF.delegate = self
        nameOfInstituteTF.delegate = self
        serialNumberTF.delegate = self
        
        descriptionTF.delegate = self
        
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = UserDefaults.standard
//        if defaults.value(forKey: "gradeCellCount") as! Int == 1 {
//            
//            print(gradeCellCount)
//            return gradeCellCount
//        }else {
            print(defaults.value(forKey: "gradeCellCount") as! Int)
            return defaults.value(forKey: "gradeCellCount") as! Int
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gradeTableView.dequeueReusableCell(withIdentifier: "GradeTableViewCellID", for: indexPath) as! GradeTabeleViewCell
        
        cell.courseNameTF.attributedPlaceholder = NSAttributedString(string: "Course name",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        cell.courseNumberTF.attributedPlaceholder = NSAttributedString(string: "Course number",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        cell.gradeTF.attributedPlaceholder = NSAttributedString(string: "Grade",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        cell.creditHourTF.attributedPlaceholder = NSAttributedString(string: "Credit Hours",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        cell.courseNumberTF.delegate = self
        cell.courseNumberTF.tag = 11+indexPath.row
        cell.courseNameTF.delegate = self
        cell.courseNameTF.tag = 21+indexPath.row
        cell.gradeTF.delegate = self
        cell.gradeTF.tag = 31+indexPath.row
        cell.creditHourTF.delegate = self
        cell.creditHourTF.tag = 41+indexPath.row
        
        let courseNumberStr = String("courseNumber\(indexPath.row+1)")
        let courseNameStr = String("courseTitle\(indexPath.row+1)")
        let gradeStr = String("grade\(indexPath.row+1)")
        let creditHourStr = String("creditHrs\(indexPath.row+1)")
        
        setUpCellData(textField: cell.courseNameTF, key: courseNameStr)
        setUpCellData(textField: cell.courseNumberTF, key: courseNumberStr)
        setUpCellData(textField: cell.gradeTF, key: gradeStr)
        setUpCellData(textField: cell.creditHourTF, key: creditHourStr)
       
        cell.backgroundColor = cell.contentView.backgroundColor
        
        return cell
    }
    
    func setUpCellData(textField: UITextField, key: String) {
        
        let tF = storeTextFInstance[key] as! UITextField
        print(tF.text!)
        textField.text = tF.text
    }
    
    
    @IBAction func segBtnPressed(_ sender: customSegBtn) {
        
        self.hideKeyboard()
        
        switch sender.tag {
            
        case 10:
            addAGradeCellBtn.isHidden = true
            sender.btnISSelecetd()
            thirdSegBtn.btnISDeselected()
            secondSegBtn.btnISDeselected()
            editTranscriptScroll.setContentOffset(CGPoint(x: 0, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
            
        case 20:
             addAGradeCellBtn.isHidden = false
             sender.btnISSelecetd()
             thirdSegBtn.btnISDeselected()
             firstSegBtn.btnISDeselected()
            editTranscriptScroll.setContentOffset(CGPoint(x: self.view.frame.size.width, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
             let defaults = UserDefaults.standard
             if defaults.value(forKey: "gradeCellCount") as! Int == 1{
                gradeArray.add("")
                gradeCellCount += 1
                //defaults.set(gradeCellCount, forKey: "gradeCellCount")
                gradeTableView.reloadData()
             }else {
                gradeCellCount = defaults.value(forKey: "gradeCellCount") as! Int
                var i = 0
                repeat {
                    gradeArray.add("")
                    i += 1
                    gradeTableView.reloadData()
                }
                while i < gradeCellCount
                
            }
            
            
        case 30:
             addAGradeCellBtn.isHidden = true
             sender.btnISSelecetd()
             firstSegBtn.btnISDeselected()
             secondSegBtn.btnISDeselected()
             editTranscriptScroll.setContentOffset(CGPoint(x: 2*self.view.frame.size.width, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
        default:
             print("")
        }
    }
    
    @IBAction func addAGradeCell(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        if gradeCellCount < 10 {
            gradeArray.add("")
            gradeCellCount += 1
            defaults.set(gradeCellCount, forKey: "gradeCellCount")
            gradeTableView.reloadData()
        }
    }
    
    @IBAction func addLogoBtnPressed(_ sender: UIButton) {
        logoPicker.allowsEditing = false
        logoPicker.sourceType = .photoLibrary
        present(logoPicker, animated:true, completion: nil)

    }
    
    @IBAction func addBarcodeBtnPressed(_ sender: UIButton) {
        barcodePicker.allowsEditing = false
        barcodePicker.sourceType = .photoLibrary
        present(barcodePicker, animated:true, completion: nil)
    }
    @IBAction func addSignBtnPressed(_ sender: UIButton) {
        storeSignImgDat = "signature"
        let signActionSheetController = UIAlertController()
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            signActionSheetController.dismiss(animated: true, completion: nil)
        }
        signActionSheetController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Upload from gallery", style: .default) { action -> Void in
            self.OpenGalleryForLogo()
            
        }
        signActionSheetController.addAction(takePictureAction)
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Sign in", style: .default) { action -> Void in
            self.hideKeyboard()
            self.view.bringSubviewToFront(self.blurEffectView)
            self.blurEffectView.isHidden = false
            self.showSignInView()
        }
        signActionSheetController.addAction(choosePictureAction)
        
        if let popoverController = signActionSheetController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(signActionSheetController, animated: true, completion: nil)

    }
    
    func OpenGalleryForLogo() {
       // storeCurrentImgView = sender
       // let imgPicker = storeCreateImgPicker[sender] as! UIImagePickerController
        signPicker.allowsEditing = false
        signPicker.sourceType = .photoLibrary
        present(signPicker, animated:true, completion: nil)
    }
    func showSignInView() {
        self.view.bringSubviewToFront(signView)
        self.view.bringSubviewToFront(signAndSealBtnHolderStackView)
        signView.isHidden = false
        signAndSealBtnHolderStackView.isHidden = false
        //uploadSealContainerView.isHidden = true
    }

    
    
    func loadBgImgView(bgImageUrlString:NSString , bgImageWidth:NSNumber ,bgImageHeight:NSNumber ) {
        
        self.image = UIImage.init(named: bgImageUrlString as String)
        self.setUpScrollView(self.image, bgWidth: CGFloat((bgImageWidth as AnyObject) .doubleValue), bgHeight: CGFloat((bgImageHeight as AnyObject) .doubleValue))
        self.saveItem.isEnabled = true
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

    
    
    func setUpScrollView(_ bgImage:UIImage,bgWidth:CGFloat,bgHeight:CGFloat) {
        
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.frame.origin.y = 70.0
        view.addSubview(scrollView)
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight))
        transcriptImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight))
        transcriptImageView.image = bgImage
        transcriptImageView.contentMode = .scaleAspectFit
        
        let sizeOfContent = transcriptImageView.frame.size.height + scrollView.frame.origin.y+10
        scrollView.contentSize.height = sizeOfContent
        scrollView.contentSize.width = transcriptImageView.bounds.size.width
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = false
        containerView.addSubview(transcriptImageView)
        
        saveContentOffset = scrollView.contentOffset
        
        scrollView.addSubview(containerView)
        containerView.backgroundColor = UIColor.clear
        scrollView.backgroundColor = UIColor.clear
        savedFrame = containerView.frame
        
        if selectedTranscriptData.count != 0 {
              fetchTextFieldData()
              fetchImageFieldsData()
              fetchTextViewData()
        }
        else {
            for txtField in (transcript.textFieldsTrans?.allObjects)!{
                updateAndBuildTf(txtField: txtField as AnyObject)
            }
            for txtView in (transcript.textViewsTrans?.allObjects)!{
                updateAndBuildTV(txtView: txtView as AnyObject)
            }
            
            for imgField in (transcript.imageFieldsTrans?.allObjects)!  {
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
                print(editImgBtn.btnData)
                if editImgBtn.btnData as! String == "logo" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                }
                else if editImgBtn.btnData as! String == "signature" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.uploadORwriteSignature(_:)), for: UIControl.Event.touchUpInside)
                }
                else if editImgBtn.btnData as! String == "barcode" {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                }
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                storeImgVInstance[name] = imgView
                storeCreateImgPicker[name] = imgPicker
            }
        }
        
        scrollView.contentOffset = saveContentOffset
//        let sx = UIScreen.main.bounds.size.width / containerView.frame.size.width
        var sx = 0.33
        if UIDevice.current.userInterfaceIdiom == .pad {
            sx = 0.66
        }
        else {
            sx = 0.33
        }
        print(sx)
        containerView.transform = CGAffineTransform(scaleX: CGFloat(sx),y: CGFloat(sx))
//        containerView.frame.origin.x = savedFrame.origin.x
        containerView.frame.origin.x = self.view.frame.size.width/2 - containerView.frame.size.width/2
        containerView.frame.origin.y = 0
        scrollView.isScrollEnabled = false
        let height = containerView.frame.size.height + scrollView.frame.origin.y
        storeYConstraintOfContentSV = height+5
//        editTranscriptScroll.
        self.view.bringSubviewToFront(editTranscriptScroll)
        self.view.bringSubviewToFront(segBtnHolderView)
        self.view.bringSubviewToFront(addAGradeCellBtn)

        setUpEditScrollViewInfo()
    }
    
    
    
    
    func fetchTextFieldData() {
        if let textFieldArray : NSArray = selectedTranscriptData.value(forKey: "textFields") as? NSArray {
            NSLog("show \(textFieldArray)")
            for aTextField in textFieldArray {
                textInfoDict = aTextField as! NSDictionary
                buildTextField(tfDict: textInfoDict)
            }
        }
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
        
        NSLog("\(aTxtfield.placeholder)")
        
        aTxtfield.font = UIFont(name: fontFamily as String, size: CGFloat((fontSize as AnyObject) .floatValue))
        aTxtfield.font = aTxtfield.font!.withSize(CGFloat((fontSize as AnyObject) .floatValue))
        
        let color = hexStringToUIColor(fontColorHex as String)
        
        
        if selectedTranscriptData.count == 0 {
            aTxtfield.text = contentText
        }
        else {
            if let text = storeTFAndTVTextDefaultsForTranscript.string(forKey: tfDict.value(forKey: "name") as! String) {
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
        
        if aTxtfield.placeholder == "Enter candidate name" || aTxtfield.placeholder == "Enter the term" || aTxtfield.placeholder == "Enter the QPTS" || aTxtfield.placeholder == "Enter current EHRS" || aTxtfield.placeholder == "Enter the gpa"{
            
            aTxtfield.textAlignment = .left
        }
        else {
            aTxtfield.textAlignment = .center
        }
        
        aTxtfield.isUserInteractionEnabled = true
        
        print("Frame before setting delegate \(aTxtfield.frame)")
        aTxtfield.delegate = self
        aTxtfield.isUserInteractionEnabled = false
        containerView.addSubview(aTxtfield)
        print("Frame before after adding subview \(aTxtfield.frame)")
        storeTextFInstance[tfDict.value(forKey: "name")!] = aTxtfield
    }
    
    func fetchTextViewData() {
        if let textViewArray : NSArray = selectedTranscriptData.value(forKey: "textViewFields") as? NSArray {
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
        
        if selectedTranscriptData.count == 0 {
            if placeHolder == "" {
                aTxtView.text = "Enter a description"
            } else {
                aTxtView.text = placeHolder
            }
        }
            
        else {
            if let text = storeTFAndTVTextDefaultsForTranscript.string(forKey: tVDict.value(forKey: "name") as! String) {
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
        
        let color = hexStringToUIColor(fontColorHex as String)
        if fontColorHex == "#000000"{
            aTxtView.textColor = UIColor.white
        }
        else {
            aTxtView.textColor = color
        }
        
        // aTxtView.borderStyle = UITextBorderStyle.none
        aTxtView.autocorrectionType = UITextAutocorrectionType.no
        aTxtView.returnKeyType = UIReturnKeyType.done
        aTxtView.backgroundColor = UIColor.clear
        storeTextVInstance[tVDict.value(forKey: "name")!] = aTxtView
    }
    
    func fetchImageFieldsData() {
        if let imgFieldsArray : NSArray = selectedTranscriptData.value(forKey: "imageFields") as? NSArray {
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
                if (editImgBtn.btnData as! String).lowercased().range(of: "barcode") != nil {
                    editImgBtn.addTarget(self, action: #selector(EditCertificateViewController.OpenAndAddSeal(_:)), for: UIControl.Event.touchUpInside)
                }
                
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                storeImgVInstance[imgInfoDict.value(forKey: "name")!] = imgView
                storeCreateImgPicker[imgInfoDict.value(forKey: "name")!] = imgPicker
            }
        }
    }
    
    
    func getPlaceHolderForTF() {
        
        if let textFieldArray : NSArray = selectedTranscriptData.value(forKey: "textFields") as?
            NSArray {
            for value in textFieldArray {
                
                NSLog("1...\(value)")
                let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                let tField = storeTextFInstance[name] as! UITextField
                
                if name == "serialNumber" {
                    
                    serialNumberTF.placeholder = tField.placeholder
                    serialNumberTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                }
                else if name == "collegeName" {
                    
                    nameOfInstituteTF.placeholder = tField.placeholder
                    nameOfInstituteTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "candidateName" {
                    
                    nameOfCandidateTF.placeholder = tField.placeholder
                    nameOfCandidateTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "term" {
                    
                    termTF.placeholder = tField.placeholder
                    termTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "currentEHRS" {
                    
                    currentEHRSTF.placeholder = tField.placeholder
                    currentEHRSTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "qpts" {
                    
                    qptsTF.placeholder = tField.placeholder
                    qptsTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "gpa" {
                    
                    gpaTF.placeholder = tField.placeholder
                    gpaTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
                else if name == "date" {
                    
                    dateTF.placeholder = tField.placeholder
                    dateTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    
                }
            }
        }

        
    }
    
    func setUpEditScrollViewInfo() {
        if selectedTranscriptData.count != 0 {
            
            self.getPlaceHolderForTF()
            gradeTableView.reloadData()
            if let imgFieldsArray : NSArray = selectedTranscriptData.value(forKey: "imageFields") as? NSArray {
                for value in imgFieldsArray {
                    let name : NSString = (value as AnyObject).value(forKey: "name") as! NSString
                    if name == "signature" {
                        addSignBtn.addTarget(self, action: #selector(addSignBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                        
                    }
                    if name == "logo" {
                        addLogoBtn.addTarget(self, action: #selector(addLogoBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                    }
                    else {
                        addBarcodeBtn.addTarget(self, action: #selector(addBarcodeBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                    }
                }
            }
            if let textViewsArray : NSArray = selectedTranscriptData.value(forKey: "textViewFields") as? NSArray {
            
                for textView in textViewsArray {
                    let name : NSString = (textView as AnyObject).value(forKey: "name") as! NSString
                    let tView = storeTextVInstance[name] as! UITextView
                    
                    if tView.text == "" {
                        
                        descriptionTF.text = "Enter a description"
                    }
                    else {
                        descriptionTF.text = tView.text
                    }
                    
                }

            }
        }
        else {
            
            let selectedTransDict : NSDictionary =  Context.getInstance().getTemplateForId(self.transcript.transcriptId) as NSDictionary
            print("show all \(selectedTransDict)")
            if let textFieldArray : NSArray = selectedTransDict.value(forKey: "textFields") as? NSArray {
                for aTextField in textFieldArray {
                    textInfoDict = aTextField as! NSDictionary
                    let name : String = textInfoDict.value(forKey: "name") as! String
                    let tField = storeTextFInstance[name] as! UITextField
                    
//                    let defaults = UserDefaults.standard
//                    serialNumberTF.text = defaults.value(forKey: "serialNumberTF") as! String?
//                    nameOfCandidateTF.text = defaults.value(forKey: "candidateNameTF") as! String?
//                    nameOfInstituteTF.text = defaults.value(forKey: "collegeNameTF") as! String?
//                    termTF.text = defaults.value(forKey: "termTF") as! String?
//                    currentEHRSTF.text = defaults.value(forKey: "currentEHRSTF") as! String?
//                    qptsTF.text = defaults.value(forKey: "qptsTF") as! String?
//                    gpaTF.text = defaults.value(forKey: "gpaTF") as! String?
//                    dateTF.text = defaults.value(forKey: "dateTF") as! String?
//                    descriptionTF.text = defaults.value(forKey: "descriptionTV") as! String!
                    if name == "serialNumber" {
                        serialNumberTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        serialNumberTF.text = tField.text
                    }
                    else if name == "collegeName" {
                        
                        nameOfInstituteTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        nameOfInstituteTF.text = tField.text
                        
                    }
                    else if name == "candidateName" {
                        nameOfCandidateTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        nameOfCandidateTF.text = tField.text
                        
                    }
                    else if name == "term" {
                        termTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        termTF.text = tField.text
                        
                    }
                    else if name == "currentEHRS" {
                        
                        
                        currentEHRSTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        currentEHRSTF.text = tField.text
                        
                    }
                    else if name == "qpts" {
                        
                        qptsTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])

                        qptsTF.text = tField.text
                        
                    }
                    else if name == "gpa" {
                        
                        gpaTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        gpaTF.text = tField.text

                        
                    }
                    else if name == "date" {
                        
                        dateTF.attributedPlaceholder = NSAttributedString(string:tField.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                        dateTF.text = tField.text
                        
                    }
                }
            }
            if let textViewArray : NSArray = selectedTransDict.value(forKey: "textViewFields") as? NSArray {
                for aTextView in textViewArray {
                    textViewInfoDict = aTextView as! NSDictionary
                    let name : String = textViewInfoDict.value(forKey: "name") as! String
                    let tView = storeTextVInstance[name] as! UITextView
                    if tView.text == "" {
                        
                        descriptionTF.text = "Enter a description"
                    }
                    else {
                        descriptionTF.text = tView.text
                    }
                }
            }
//            if let imageData = transcript.value(forKey: "image") as? Data {
//
//                transcriptImageView.image = UIImage(data: imageData, scale: 1)
//            }

            if let imgViewArray :NSArray = selectedTransDict.value(forKey: "imageFields") as? NSArray {
                
                for aImgView in imgViewArray {
                    imgInfoDict = aImgView as! NSDictionary
                    
                    print(imgInfoDict)
                    
                    let name : String = imgInfoDict.value(forKey: "name") as! String
                    if name == "signature" {
                        addSignBtn.addTarget(self, action: #selector(addSignBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                        
                    }
                    if name == "logo" {
                        addLogoBtn.addTarget(self, action: #selector(addLogoBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                    }
                    else {
                        addBarcodeBtn.addTarget(self, action: #selector(addBarcodeBtnPressed(_:)), for: UIControl.Event.touchUpInside)
                    }
                }
            }
        }
        
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == dateTF {
//            return false
//        }else {
//            return true
//        }
//    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField)
                
        if textField == nameOfCandidateTF {
            
        }
        if textField == nameOfInstituteTF {
            
        }
        if textField == serialNumberTF {
            
        }
        if textField == gpaTF {
            
        }
        if textField == qptsTF {
            
        }
        if textField == termTF {
            
        }
        if textField == currentEHRSTF {
            
        }
        
        if textField == dateTF {
            isKeyboardVisible = true
                //showDatePicker()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
//        let textF = storeTextFInstance.object(forKey: tF.txtFData as! String) as! UITextField
//        textF.text = textField.text
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        print(newString)
        
        if textField == nameOfCandidateTF {
            setUpTFData(textField: textField, key: "candidateName", text: newString as String)
            
        }
        if textField == nameOfInstituteTF {
            setUpTFData(textField: textField, key: "collegeName", text: newString as String)
        }
        if textField == serialNumberTF {
            setUpTFData(textField: textField, key: "serialNumber", text: newString as String)
        }
        if textField == gpaTF {
            setUpTFData(textField: textField, key: "gpa", text: newString as String)
        }
        if textField == qptsTF {
            setUpTFData(textField: textField, key: "qpts", text: newString as String)
        }
        if textField == termTF {
            setUpTFData(textField: textField, key: "term", text: newString as String)
        }
        if textField == currentEHRSTF {
            setUpTFData(textField: textField, key: "currentEHRS", text: newString as String)
        }
        if textField == dateTF {
            dateTF.resignFirstResponder()
        }
        if (11...20).contains(textField.tag) {
            
            var i = textField.tag % 10
            
            if i == 0 {
                i = 10
            }
            let courseNumberStr = String("courseNumber\(i)")
            setUpTFData(textField: textField, key: courseNumberStr, text: newString as String)
        }
        if (21...30).contains(textField.tag) {
            
            var i = textField.tag % 10
            
            if i == 0 {
                i = 10
            }
            let courseTitleStr = String("courseTitle\(i)")
            setUpTFData(textField: textField, key: courseTitleStr, text: newString as String)
        }
        if (31...40).contains(textField.tag) {
            
            var i = textField.tag % 10
            
            if i == 0 {
                i = 10
            }
            let gradeStr = String("grade\(i)")
            setUpTFData(textField: textField, key: gradeStr, text: newString as String)
        }
        if (41...50).contains(textField.tag) {
            
            var i = textField.tag % 10
            
            if i == 0 {
                i = 10
            }
            let creditHrsStr = String("creditHrs\(i)")
            setUpTFData(textField: textField, key: creditHrsStr, text: newString as String)
        }
        
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
        
    }
    
    func setUpTFData(textField:UITextField,key:String, text:String) {
        NSLog("key is \(key)")
        NSLog("key is \(text)")
        let tf = storeTextFInstance[key] as! UITextField
        tf.text = text
        NSLog("key is \(tf.text)")
        if tf.text == "" {
            textField.text = ""
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = editTranscriptScroll.contentOffset.x
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(editTranscriptScroll.contentOffset.x)
        
        if scrollView.isDragging == true {
            if self.lastContentOffset < editTranscriptScroll.contentOffset.x {
                if editTranscriptScroll.contentOffset.x > 0 && editTranscriptScroll.contentOffset.x < self.view.frame.size.width {
                    firstSegBtn.btnISDeselected()
                    thirdSegBtn.btnISSelecetd()
                    secondSegBtn.btnISDeselected()
                    addAGradeCellBtn.isHidden = false
                    editTranscriptScroll.setContentOffset(CGPoint(x: self.view.frame.size.width, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
                }
                if editTranscriptScroll.contentOffset.x > self.view.frame.size.width && editTranscriptScroll.contentOffset.x < 2 * self.view.frame.size.width {
                    addAGradeCellBtn.isHidden = true
                    firstSegBtn.btnISDeselected()
                    thirdSegBtn.btnISDeselected()
                    secondSegBtn.btnISSelecetd()
                    editTranscriptScroll.setContentOffset(CGPoint(x: 2*self.view.frame.size.width, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
                }
                // moved right
            } else if self.lastContentOffset > editTranscriptScroll.contentOffset.x {
                if editTranscriptScroll.contentOffset.x > 2 * self.view.frame.size.width {
                    addAGradeCellBtn.isHidden = false
                    firstSegBtn.btnISDeselected()
                    thirdSegBtn.btnISSelecetd()
                    secondSegBtn.btnISDeselected()
                    self.editTranscriptScroll.setContentOffset(CGPoint(x: self.view.frame.size.width, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
                }
                
                if editTranscriptScroll.contentOffset.x > self.view.frame.size.width && editTranscriptScroll.contentOffset.x < 2 * self.view.frame.size.width {
                    firstSegBtn.btnISSelecetd()
                    thirdSegBtn.btnISDeselected()
                    secondSegBtn.btnISDeselected()
                    addAGradeCellBtn.isHidden = true
                    self.editTranscriptScroll.setContentOffset(CGPoint(x: 0, y: self.editTranscriptScroll.bounds.origin.y), animated: true)
                }
                // moved left
            }
        }
        
       
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Enter a description" {
            
            textView.text = ""
        }
        
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
//        segBtnHolderView?.isHidden = false
        textView.resignFirstResponder()
        
//        let textV = storeTextVInstance.object(forKey: tV.txtVData as! String) as! UITextView
//        if textV.text == "" {
//            tV.text = "Enter a description"
//        }
//        textV.text = tV.text
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == descriptionTF {
            let tf = storeTextVInstance["description"] as! UITextView
            tf.text = textView.text
        }
        if(text == "\n")
        {
            if textView.text == "" {
                textView.text = "Enter a description"
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func showDatePicker() {
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
        datePicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let tField = storeTextFInstance["date"] as! UITextField
        tField.text = dateFormatter.string(from: sender.date)
        dateTF.text = tField.text
    }
    
    @IBAction func cancelDatePicker(_ sender: AnyObject) {
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let tField = storeTextFInstance["date"] as! UITextField
        tField.text = dateFormatter.string(from: datePicker.date)
        print(dateFormatter.string(from: datePicker.date))
        dateTF.text = tField.text
        hideDatePicker()
    }
    
    func hideKeyboard() {
        
        termTF.resignFirstResponder()
        currentEHRSTF.resignFirstResponder()
        qptsTF.resignFirstResponder()
        gpaTF.resignFirstResponder()
        dateTF.resignFirstResponder()
        
        nameOfCandidateTF.resignFirstResponder()
        nameOfInstituteTF.resignFirstResponder()
        serialNumberTF.resignFirstResponder()
        descriptionTF.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if picker == logoPicker {
            let imgView = storeImgVInstance["logo"] as! UIImageView
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
             {
             imgView.image = pickedImage
             }
        }
        else if picker == signPicker {
            let imgView = storeImgVInstance["signature"] as! UIImageView
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
            {
                imgView.image = pickedImage
            }
        }
        else if picker == barcodePicker {
            let imgView = storeImgVInstance["barcode"] as! UIImageView
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
            {
                imgView.image = pickedImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Adding image to album
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
