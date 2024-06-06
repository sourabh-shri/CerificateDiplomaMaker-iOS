//
//  TemplateVIewController.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/1/16.
//  Copyright © 2016 Mobiona. All rights reserved.


import UIKit
import CoreData

class TemplateVIewController: UIViewController,UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SetTextFieldDataDelegate,CanceBtnPressedDelegate,SetTextViewDataDelegate {
    
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
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
    
    var editTextBtn : UIButton!
    var editImgBtn : UIButton!
    
    let signImgPicker = UIImagePickerController()
    let logoImgPicker = UIImagePickerController()
    
    
    var popUpView = PopUpVIew()

    
    var btnTag = 0
    var scaleViwItem = UIBarButtonItem()
    var saveItem = UIBarButtonItem()
    var scaleBtnTag = 0
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    var savedFrame = CGRect()
    var saveContentOffset = CGPoint()
    var cert : DBCertificate!

    
    let managedObjContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad(){
        super.viewDidLoad()
        
        activityInd.isHidden = false
        activityInd.startAnimating()


        let backItem = UIBarButtonItem(image:UIImage(named: "nav_back.png"), landscapeImagePhone: UIImage(named: "nav_back.png"), style: .plain, target: self, action: #selector(TemplateVIewController.Cancel))

        navigationItem.leftBarButtonItem = backItem
        
        saveItem = UIBarButtonItem(image:UIImage(named: "nav_save_btn.png"), landscapeImagePhone: UIImage(named: "nav_save_btn.png"), style: .plain, target: self, action: #selector(TemplateVIewController.Save))
        saveItem.tintColor = UIColor.white
        
        scaleViwItem = UIBarButtonItem(image:  UIImage(named: "nav_zoomOut.png"), landscapeImagePhone:  UIImage(named: "nav_zoomOut.png"), style: .plain, target: self, action: #selector(TemplateVIewController.ScaleTheView))
        scaleViwItem.tag = 1
        scaleBtnTag = scaleViwItem.tag
        navigationItem.setRightBarButtonItems([scaleViwItem,saveItem], animated: true)
        
        if cert == nil {
            navigationItem.title = "New"
        }
        else {
            navigationItem.title = cert.certificateTitle
        }
        
        scaleViwItem.isEnabled = false
        saveItem.isEnabled = false

        
        
        loadPoPUpView()

//      signImgPicker.delegate = self
        logoImgPicker.delegate = self
        
        popUpView.delegate = self
        popUpView.delegate2 = self
        popUpView.delegate3 = self

        
        
        if selectedTemplateData.count != 0 {
            loadBgImgView(bgImageUrlString: selectedTemplateData.value(forKey: "bgImageUrl") as! NSString, bgImageWidth: self.selectedTemplateData.value(forKey: "widthInPixels")! as! NSNumber, bgImageHeight: self.selectedTemplateData.value(forKey: "heightInPixels")! as! NSNumber)
        }
}

    func loadBgImgView(bgImageUrlString:NSString , bgImageWidth:NSNumber ,bgImageHeight:NSNumber ) {
        
        DispatchQueue.global(qos: .background).async {
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
                    self.scaleViwItem.isEnabled = true
                    self.saveItem.isEnabled = true
                    self.activityInd.isHidden = true
                    self.activityInd.stopAnimating()
                }
            });
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func Cancel(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func Save(){
        
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
                (UIApplication.shared.delegate as! AppDelegate).showUpgradePopup(viewController: self)
                return
            }
        }

        let sizeOfContent = templateImageView.frame.size.height + scrollView.frame.origin.y+10
        scrollView.contentSize.height = sizeOfContent
        scrollView.contentSize.width = templateImageView.bounds.size.width
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        askTitleAndthenSave()
    }
    
    func storeCertificateDatatoDB(_ cert: DBCertificate) {
        let newCertificateObject = cert

        newCertificateObject.setValue(Date(), forKey: "dateCreated")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "templateId"), forKey: "templateId")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "organization"), forKey: "organization")
        newCertificateObject.setValue(selectedTemplateData.value(forKey: "bgImageUrl"), forKey: "templateBgImageUrl")
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
    
    func updateImgfAndTfData(_ cert : DBCertificate) {
        let newCertificateObject = cert
        for txtField in (cert.textFields?.allObjects)!{
            let name: String = (txtField as! DBTextField).templateName!
            passTFData(txtField as! DBTextField, txtField: storeTextFInstance[name] as! UITextField)
            (txtField as! DBTextField).setValue(name, forKey: "templateName")
            newCertificateObject.addToTextFields(txtField as! DBTextField)
        }
        
        for imgField in (cert.imageFields?.allObjects)!  {
            let name : String = (imgField as! DBImageField).templateName!
            let imgView = storeImgVInstance[name] as! UIImageView
            passIMGFieldData(imgField as! DBImageField, imgView: imgView)
            (imgField as! DBImageField).setValue(name, forKey: "templateName")
            newCertificateObject.addToImageFields(imgField as! DBImageField)
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
        dbTf.setValue(fontFace, forKey: "fontFace")
        dbTf.setValue(hexTextColor, forKey: "fontColorHex")
        dbTf.setValue(txtView.text, forKey: "content")
//        dbTf.setValue(txtField.placeholder, forKey: "placeholder")
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
    

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false; //do not show keyboard nor cursor
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
                editImgBtn.addTarget(self, action: #selector(TemplateVIewController.OpenGalleryForLogo(_:)), for: UIControl.Event.touchUpInside)
                containerView.addSubview(editImgBtn)
                editImgBtn.btnData = name as NSString
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                storeImgVInstance[name] = imgView
                storeCreateImgPicker[name] = imgPicker
            }

        }
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
//            "placeholder" : (txtView as! DBTextView).placeholder! as AnyObject ,
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
//      aTxtView.delegate = self
        containerView.addSubview(aTxtView)
        
        var fontFamily: String = tVDict.value(forKey: "fontFamily")as! String
        let fontFace: String = tVDict.value(forKey: "fontFace")as! String
        let fontColorHex: String = tVDict.value(forKey: "fontColorHex")as! String
//        let placeHolder: String = tVDict.value(forKey: "placeholder")as! String
        let contentText: String = tVDict.value(forKey: "content")as! String
        let fontSize = tVDict.value(forKey: "fontSize")!
        if fontFace != "" {
            fontFamily = (fontFamily as String)+"-"+(fontFace as String)
        }
        
//      aTxtView.placeholder = placeHolder as String
        aTxtView.font = UIFont(name: fontFamily as String, size: CGFloat((fontSize as AnyObject) .floatValue))
        let color = hexStringToUIColor(fontColorHex as String)
        aTxtView.text = contentText
        aTxtView.textColor = color
//      aTxtView.borderStyle = UITextBorderStyle.none
        aTxtView.autocorrectionType = UITextAutocorrectionType.no
        aTxtView.returnKeyType = UIReturnKeyType.done
        aTxtView.backgroundColor = UIColor.clear
        
        let editBtn = CustomUIButton(frame: CGRect(x: aTxtView.frame.origin.x, y: aTxtView.frame.origin.y, width: aTxtView.frame.size.width, height: aTxtView.frame.size.height))

        editBtn.addTarget(self, action: #selector(TemplateVIewController.OpenCustomizePopUpForTextView(_:)), for: UIControl.Event.touchUpInside)
        containerView.addSubview(editBtn)
        editBtn.btnData = aTxtView
        // store the tField Instance to dictionary
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
        aTxtfield.delegate = self
        containerView.addSubview(aTxtfield)

        var fontFamily: String = tfDict.value(forKey: "fontFamily")as! String
        let fontFace: String = tfDict.value(forKey: "fontFace")as! String
        let fontColorHex: String = tfDict.value(forKey: "fontColorHex")as! String
        let placeHolder: String = tfDict.value(forKey: "placeholder")as! String
        let contentText: String = tfDict.value(forKey: "content")as! String
        let fontSize = tfDict.value(forKey: "fontSize")!
        if fontFace != "" {
            fontFamily = (fontFamily as String)+"-"+(fontFace as String)
        }

        aTxtfield.placeholder = placeHolder as String
        aTxtfield.font = UIFont(name: fontFamily as String, size: CGFloat((fontSize as AnyObject) .floatValue))
        let color = hexStringToUIColor(fontColorHex as String)
        aTxtfield.text = contentText
        aTxtfield.textColor = color
        aTxtfield.borderStyle = UITextField.BorderStyle.none
        aTxtfield.autocorrectionType = UITextAutocorrectionType.no
        aTxtfield.returnKeyType = UIReturnKeyType.done
        aTxtfield.textAlignment = .center

        let editBtn = CustomUIButton(frame: CGRect(x: aTxtfield.frame.origin.x, y: aTxtfield.frame.origin.y, width: aTxtfield.frame.size.width, height: aTxtfield.frame.size.height))
        editBtn.btnData = aTxtfield
        if (tfDict.value(forKey: "name")as! String).isEqual("date") {
            btnTag = 3
        }
        else {
             btnTag = 0
        }
        editBtn.addTarget(self, action: #selector(TemplateVIewController.OpenCustomizePopUp(_:)), for: UIControl.Event.touchUpInside)
        containerView.addSubview(editBtn)
        
        editBtn.tag = btnTag
        // store the tField Instance to dictionary
        storeTextFInstance[tfDict.value(forKey: "name")!] = aTxtfield
    }

    func fetchImageFieldsData() {
        if let imgFieldsArray : NSArray = selectedTemplateData.value(forKey: "imageFields") as? NSArray {
            for value in imgFieldsArray {
                imgInfoDict = value as! NSDictionary
                let logoImgUrl : NSString = imgInfoDict.value(forKey: "Url") as! NSString
                let imageURL = URL(string: logoImgUrl as String)
                let data:Data?  = try? Data(contentsOf: imageURL!)
                self.image = UIImage(data: data!)
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
                editImgBtn.addTarget(self, action: #selector(TemplateVIewController.OpenGalleryForLogo(_:)), for: UIControl.Event.touchUpInside)
                containerView.addSubview(editImgBtn)
                editImgBtn.btnData = imgInfoDict.value(forKey: "name") as! NSString

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
    
    
    @objc func OpenCustomizePopUpForTextView(_ sender:CustomUIButton!) {
        let txtVw = sender.btnData as! UITextView
        showPopUpView()
        storeCurrentTextView = txtVw
        popUpView.setUpTextView(txtVw)
    }

    @objc func OpenCustomizePopUp(_ sender:CustomUIButton!) {
        let txtfd = sender.btnData as! UITextField
        showPopUpView()
        storeCurrentTxtField = txtfd
        popUpView.setUpTextField(txtfd,tag:sender.tag)
    }
    
    func showPopUpView() {
        popUpView.isHidden = false
        self.view.bringSubviewToFront(popUpView)
        navigationController?.isNavigationBarHidden = true
    }
    
    func hidePopUpView(_ popView : PopUpVIew) {
        navigationController?.isNavigationBarHidden = false
        popView.isHidden = true
        self.view.sendSubviewToBack(popView)
    }
    
    func loadPoPUpView(){
        popUpView = (Bundle.main.loadNibNamed("PopUpVIew", owner: self, options: nil)?.first as? PopUpVIew)!
        popUpView.frame = self.view.frame
        self.view.addSubview(popUpView)
        self.view.bringSubviewToFront(popUpView)
        hidePopUpView(popUpView)
    }

    func setTextField(_ pView:PopUpVIew) {
        storeCurrentTxtField.text = pView.customizeableTextField.text
        storeCurrentTxtField.textColor = pView.customizeableTextField.textColor
        storeCurrentTxtField.font = pView.customizeableTextField.font
        hidePopUpView(pView)
    }
    
    func setTextView(_ pView: PopUpVIew) {
        storeCurrentTextView.text = pView.customizeableTextView.text
        storeCurrentTextView.textColor = pView.customizeableTextView.textColor
        storeCurrentTextView.font = pView.customizeableTextView.font
        hidePopUpView(pView)
    }
    
    func cancelTheView(_ pView: PopUpVIew) {
        hidePopUpView(pView)
    }
    
   
    // surya :- open gallery for selecting logo image
    @objc func OpenGalleryForLogo(_ sender:CustomUIButton!) {
        storeCurrentImgView = sender.btnData as! String 
        let imgPicker = storeCreateImgPicker[sender.btnData] as! UIImagePickerController
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
        let date :Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd_yyyy'_'HH:mm:ss"
        let imageName = "/\(savedName)_\(dateFormatter.string(from: date)).png"
        var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDirectoryPath += imageName
        let imgData : Data = sampleImage.pngData()!
        try? imgData.write(to: URL(fileURLWithPath: documentsDirectoryPath), options: [.atomic])
        return imgData
    }
    
// Surya :- ask nave befor save , then save to Core Data or update to Core Data and save to gallery
    func askTitleAndthenSave () {
        var titleTextField: UITextField?
        let alertController = UIAlertController(
            title: "Title",
            message: "Please enter a title to save your certificate",
            preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(
            title: "Save", style: UIAlertAction.Style.default) {
            (action) -> Void in
            if let title = titleTextField?.text {
                    if title.count > 3 {
                    if self.cert == nil {
                        self.cert = NSEntityDescription.insertNewObject(forEntityName: "DBCertificate", into: self.managedObjContext) as! DBCertificate
                        self.storeCertificateDatatoDB(self.cert)
                        self.storeImgFieldAndTfAndTviewData(self.cert)
                    }
                    else {
                        self.updateCertificateDatatoDB(self.cert)
                        self.updateImgfAndTfData(self.cert)
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
                } else {
                    titleTextField?.becomeFirstResponder()
                    let alertController = UIAlertController(
                        title: "🙁 Error. Please Resave.",
                        message: "Name should contain maximum 3 letters and should not be start with space.",
                        preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(
                        title: "OK", style: UIAlertAction.Style.default) {
                        (action) -> Void in
                        self.dismiss(animated: true, completion: nil)
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
            title: "Cancel", style: UIAlertAction.Style.default) {
            (action) -> Void in
            self.dismiss(animated: true, completion: nil)
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
        
    }
    
    // Surya :- zoom in and zoom out the view
    @objc func ScaleTheView() {
            if scaleBtnTag == 1 {
                scrollView.contentOffset = saveContentOffset
                let sx = UIScreen.main.bounds.size.width / containerView.frame.size.width
                containerView.transform = CGAffineTransform(scaleX: sx,y: sx)
                containerView.frame.origin.x = savedFrame.origin.x
                containerView.frame.origin.y = UIScreen.main.bounds.size.height/2.0 - containerView.frame.size.height/2.0 - 44.0
                scrollView.isScrollEnabled = false
                scaleViwItem.image = UIImage(named: "zoom-in")
                scaleBtnTag = 2
            }
            else {
                scaleBtnTag = 1
                containerView.transform = CGAffineTransform.identity
                containerView.frame = savedFrame
                containerView.frame.origin.x = 0
                containerView.frame.origin.y = 0
                scrollView.isScrollEnabled = true
                scaleViwItem.image = UIImage(named: "nav_zoomOut.png")
            }
    }
}
