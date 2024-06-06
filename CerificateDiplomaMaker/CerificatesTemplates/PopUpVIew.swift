  //
//  PopUpVIew.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/3/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol SetTextFieldDataDelegate : class {
    func setTextField(_ pView:PopUpVIew)
}
  
protocol SetTextViewDataDelegate : class {
    func setTextView(_ pView:PopUpVIew)
}

protocol CanceBtnPressedDelegate : class {
    func cancelTheView(_ pView:PopUpVIew)
}
  


class PopUpVIew: UIView,UITableViewDataSource,UITableViewDelegate,SwiftHSVColorPickerDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var changeFontBtn: UIButton!
    @IBOutlet weak var changeFontSizeBtn: UIButton!
    @IBOutlet weak var changeFontColorBtn: UIButton!
    
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var containerView: UIView!
   
    let scrollView = UIScrollView()
    
    
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var doneDatePicker: UIButton!
    
    weak var delegate: SetTextFieldDataDelegate?
    weak var delegate2: CanceBtnPressedDelegate?
    weak var delegate3: SetTextViewDataDelegate?


    var customizeableTextField = UITextField()
    var customizeableTextView = UITextView()
    
//    var customizeableTFOrTV : AnyObject!
    var selectedCustomizeableTFOrTV : String!

    
    @IBOutlet weak var fontSizeTxtField: UITextField!
    @IBOutlet weak var fontListTableView: UITableView!
    @IBOutlet weak var txtColorHexCode: UITextField!
    
    @IBOutlet var colorPicker: SwiftHSVColorPicker!
    var dattxtFieldBtn :UIButton!
    
    var line = UIView()
    var fontSize = CGFloat()
    var selectedFontName = String()
     
    var fontArray : NSMutableArray=[]

    @IBOutlet weak var datePickerBckView: UIView!
    @IBOutlet weak var fontStepper: UIStepper!
    
    var selectedColor: UIColor!
    
    var textFieldTag: Int = 0
    
    @IBOutlet weak var cancelBtnBackView: UIView!
    @IBOutlet weak var applyBtnBackView: UIView!
    
    override func awakeFromNib() {
        colorPicker.delegate = self
        setFontListArray()
        datePickerBckView.isHidden = true
        
        datePicker.isHidden = true
        doneDatePicker.isHidden = true
        datePicker.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fontSizeTxtField.delegate = self
        txtColorHexCode.delegate = self
        
        fontListTableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08)
        
        cancelBtnBackView.layer.cornerRadius = 15
        cancelBtnBackView.layer.masksToBounds = true
        
        applyBtnBackView.layer.cornerRadius = 15
        applyBtnBackView.layer.masksToBounds = true

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardSize.height)
                containerView.frame.origin.y -= keyboardSize.height-30
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                containerView.frame.origin.y += keyboardSize.height-30
        }
    }
    
    func customizeStepper() {

    }
    
    func setUpScrollView(){
//        scrollView.center  =  containerView.center
        scrollView.frame.origin.x = 0
        scrollView.frame.origin.y = 0
        scrollView.frame.size.width = containerView.frame.size.width
        
        if UIScreen.main.bounds.size.width == 768.0 {
              scrollView.frame.size.height = 120
        }
        else {
            scrollView.frame.size.height = 60
        }
        scrollView.backgroundColor = UIColor.clear
        containerView.addSubview(scrollView)
    }
    
    func setUpTextField(_ txtField:UITextField,tag:Int) {
        customizeableTextField.frame.size = txtField.frame.size
        customizeableTextField.frame.origin.y = 10 // change from 30
        setUpScrollView()
        
        if customizeableTextField.frame.size.width > scrollView.frame.size.width {
            customizeableTextField.frame.origin.x = 0
        }
        else {
            customizeableTextField.frame.origin.x = self.frame.size.width / 2 - txtField.frame.size.width / 2
        }
        
        scrollView.contentSize.height = customizeableTextField.frame.size.height + 10
        scrollView.contentSize.width = customizeableTextField.frame.size.width
        

        print(scrollView.frame)
        print(customizeableTextField.frame)

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = false
        scrollView.addSubview(customizeableTextField)
        customizeableTextField.backgroundColor = UIColor.clear
        
        customizeableTextField.text = txtField.text
        customizeableTextField.placeholder = txtField.placeholder
        customizeableTextField.textColor = txtField.textColor
        customizeableTextField.font = txtField.font
        customizeableTextField.textAlignment = txtField.textAlignment
        
        if let placeholder = customizeableTextField.placeholder {
            customizeableTextField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        
        fillUpData(customizeableTextField)
        
        line = UIView(frame: CGRect(x: customizeableTextField.frame.origin.x, y: customizeableTextField.frame.origin.y+customizeableTextField.frame.size.height, width: customizeableTextField.frame.size.width, height: 2))
        line.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.35)
        scrollView.addSubview(line)
        selectedFontName = (customizeableTextField.font?.fontName)!
        
      customizeableTextField.delegate = self
        textFieldTag = tag
        if textFieldTag == 3 {
            dattxtFieldBtn = UIButton(frame: CGRect(x: customizeableTextField.frame.origin.x, y: customizeableTextField.frame.origin.y, width: customizeableTextField.frame.size.width, height: customizeableTextField.frame.size.height))
            dattxtFieldBtn.addTarget(self, action: #selector(PopUpVIew.OpenDatePickerPopUp(_:)), for: UIControl.Event.touchUpInside)
            scrollView.addSubview(dattxtFieldBtn)
        }
        
        print(customizeableTextView)

        
        fontSizeTxtField.delegate = self
        txtColorHexCode.delegate = self
        fontSizeTxtField.textAlignment = .center
        
        fontSizeTxtField.addTarget(self, action: #selector(PopUpVIew.changeFontSizeTF(_:)), for: UIControl.Event.editingChanged)
        
        txtColorHexCode.addTarget(self, action: #selector(PopUpVIew.changeHexColorTF(_:)), for: UIControl.Event.editingChanged)
                
        txtColorHexCode.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        txtColorHexCode.textAlignment = .center
        selectedCustomizeableTFOrTV = "customizeableTextField"
    }
    
    func setUpTextView(_ txtView:UITextView) {
        customizeableTextView.frame.size = txtView.frame.size
        customizeableTextView.frame.origin.y = 10 // change from 30
        setUpScrollView()
        
        if customizeableTextView.frame.size.width > scrollView.frame.size.width {
            customizeableTextView.frame.origin.x = 0
        }
        else {
            customizeableTextView.frame.origin.x = self.frame.size.width / 2 - txtView.frame.size.width / 2
        }
        
        scrollView.contentSize.height = customizeableTextView.frame.size.height + 10
        scrollView.contentSize.width = customizeableTextView.frame.size.width
        
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = false
        scrollView.addSubview(customizeableTextView)
        customizeableTextView.backgroundColor = UIColor.clear
        
        customizeableTextView.text = txtView.text
//        customizeableTextView.placeholder = txtField.placeholder
        customizeableTextView.textColor = txtView.textColor
        customizeableTextView.font = txtView.font
        customizeableTextView.textAlignment = txtView.textAlignment
        
        fillUpData(customizeableTextView)
        
        print(customizeableTextField)
        line = UIView(frame: CGRect(x: customizeableTextView.frame.origin.x, y: customizeableTextView.frame.origin.y+customizeableTextView.frame.size.height, width: customizeableTextView.frame.size.width, height: 2))
        line.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.35)
        scrollView.addSubview(line)
        selectedFontName = (customizeableTextView.font?.fontName)!
        
        fontSizeTxtField.delegate = self
        txtColorHexCode.delegate = self
        fontSizeTxtField.textAlignment = .center
        
        fontSizeTxtField.addTarget(self, action: #selector(PopUpVIew.changeFontSizeTV(_:)), for: UIControl.Event.editingChanged)
        
        txtColorHexCode.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        txtColorHexCode.textAlignment = .center
        customizeableTextView.delegate = self
        selectedCustomizeableTFOrTV = "customizeableTextView"
    }
    
    @objc func changeFontSizeTV(_ txtView:UITextView){
        let fontSize1: CGFloat = CGFloat((txtView.text! as NSString).doubleValue)
        print(fontSize1)
        fontSize = fontSize1
        customizeableTextView.font = UIFont(name: selectedFontName, size: fontSize1)
        fontStepper.value = Double(fontSize1)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customizeableTextField.resignFirstResponder()
        fontSizeTxtField.resignFirstResponder()
        txtColorHexCode.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            customizeableTextView.resignFirstResponder()
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == fontSizeTxtField {
            customizeableTextField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            fontSizeTxtField.text = ""
        }
        else if textField == txtColorHexCode {
            customizeableTextField.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.text = "#"
        }
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == customizeableTextField {
            txtColorHexCode.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            return true
        }
        else if textField == fontSizeTxtField {
            customizeableTextField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            return true
        }
        else if textField == txtColorHexCode {
            customizeableTextField.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            return true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == txtColorHexCode && textField.text?.count == 0 {
            txtColorHexCode.text = "#"
        }
        else if textField == txtColorHexCode {
            // changing 6 to 8
            if textField.text?.count > 6 {
                return false
            }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == fontSizeTxtField {
            let fontSize1: CGFloat = CGFloat((textField.text! as NSString).doubleValue)
            fontSizeTxtField.text = "\(fontSize1)"
        }
        else if textField == txtColorHexCode {
            let color = hexStringToUIColor(textField.text! as String)
            
            if selectedCustomizeableTFOrTV == "customizeableTextView" {
                customizeableTextView.textColor = color
            }
            else if selectedCustomizeableTFOrTV == "customizeableTextField"{
                customizeableTextField.textColor = color
            }
            colorPicker.setViewColor(color)
        }
    }
    
    @objc func changeFontSizeTF(_ txtField:UITextField){
        let fontSize1: CGFloat = CGFloat((txtField.text! as NSString).doubleValue)
        print(fontSize1)
        fontSize = fontSize1
        customizeableTextField.font = UIFont(name: selectedFontName, size: fontSize1)
        fontStepper.value = Double(fontSize1)
    }
    
    @objc func changeHexColorTF(_ txtField:UITextField){
        
    }

    @objc func OpenDatePickerPopUp(_ sender:UIButton!) {
        if textFieldTag == 3{
            datePickerBckView.isHidden = false
            datePicker.isHidden = false
            doneDatePicker.isHidden = false
        }
    }

    
    @IBAction func cancelBtnPressed(_ sender: UIButton){
        customizeableTextField.resignFirstResponder()
        fontSizeTxtField.resignFirstResponder()
        txtColorHexCode.resignFirstResponder()
        delegate2?.cancelTheView(self)
//        self.hidden = true
        line.removeFromSuperview()
    }
    
    @IBAction func applyBtnPressed(_ sender: UIButton) {
//      tvc.applyChangesToTF(customizeableTextField, tag:textFieldTag)
        customizeableTextField.resignFirstResponder()
        fontSizeTxtField.resignFirstResponder()
        txtColorHexCode.resignFirstResponder()
        
        if selectedCustomizeableTFOrTV == "customizeableTextView" {
            delegate3?.setTextView(self)
            customizeableTextView.removeFromSuperview()
        }
        else if selectedCustomizeableTFOrTV == "customizeableTextField"{
            delegate?.setTextField(self)
            customizeableTextField.removeFromSuperview()
        }
        line.removeFromSuperview()
    }
    
//    func fillUpData(_ txtData:UITextField){
//        // set initial color to textField
//        selectedColor = txtData.textColor!
//        colorPicker.setViewColor(selectedColor)
//        print(selectedColor)
//        
//        fontSize = (txtData.font?.pointSize)!
//        fontStepper.value = Double(fontSize)
//        fontSizeTxtField.text = "\(fontSize)"
//        
//        print(hexStringFromUIColor(customizeableTextField.textColor!))
//        setHexString(customizeableTextField.textColor!)
//    }
    
    func fillUpData(_ txtData:AnyObject){
        
        if txtData as? UITextField == customizeableTextField {
            // set initial color to textField
            selectedColor = txtData.textColor!
            colorPicker.setViewColor(selectedColor)
            print(selectedColor)
            
            fontSize = (txtData.font?.pointSize)!
            fontStepper.value = Double(fontSize)
            fontSizeTxtField.text = "\(fontSize)"
            
            print(hexStringFromUIColor(customizeableTextField.textColor!))
            setHexString(customizeableTextField.textColor!)
        }
        
        else if txtData as? UITextView == customizeableTextView {
            selectedColor = txtData.textColor!
            colorPicker.setViewColor(selectedColor)
            
            fontSize = (txtData.font?.pointSize)!
            fontStepper.value = Double(fontSize)
            fontSizeTxtField.text = "\(fontSize)"
            setHexString(customizeableTextView.textColor!)
        }
    }
    
    @IBAction func changeFontSize(_ sender: UIStepper) {
        fontSize = CGFloat(sender.value)
        fontSizeTxtField.text = "\(sender.value)"
        if selectedCustomizeableTFOrTV == "customizeableTextView" {
            customizeableTextView.font = UIFont(name: selectedFontName, size: fontSize)
        }
        else if selectedCustomizeableTFOrTV == "customizeableTextField"{
            customizeableTextField.font = UIFont(name: selectedFontName, size: fontSize)
        }
    }

    
    func setFontListArray(){
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            fontArray = dict["UIAppFonts"]! as! NSMutableArray
            fontListTableView.delegate = self
            fontListTableView.dataSource = self
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = FontCell()
        let nibName = UINib(nibName: "FontCell", bundle:nil)
        fontListTableView.register(nibName, forCellReuseIdentifier: "CellID")
        cell = fontListTableView.dequeueReusableCell(withIdentifier: "CellID") as! FontCell
        cell.backgroundColor = UIColor.clear
         cell.textLabel?.text = fontArray.object(at: indexPath.row) as? String
        if let dotRange = cell.textLabel?.text!.range(of: ".") {
            cell.textLabel?.text!.removeSubrange(dotRange.lowerBound..<(cell.textLabel?.text!.endIndex)!)
        }
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name:(cell.textLabel?.text)!, size:22)
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .default

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFontName = fontArray.object(at: indexPath.row) as! String
        if let dotRange = selectedFontName.range(of: ".") {
            selectedFontName.removeSubrange(dotRange.lowerBound..<selectedFontName.endIndex)
        }
        if selectedCustomizeableTFOrTV == "customizeableTextView" {
            customizeableTextView.font = UIFont(name: selectedFontName, size: fontSize)
        }
        else if selectedCustomizeableTFOrTV == "customizeableTextField"{
            customizeableTextField.font = UIFont(name: selectedFontName, size: fontSize)
        }
    }
    
    func setTextColor(_ pView:SwiftHSVColorPicker){
        if selectedCustomizeableTFOrTV == "customizeableTextView" {
            customizeableTextView.textColor = pView.color
        }
        else if selectedCustomizeableTFOrTV == "customizeableTextField"{
            customizeableTextField.textColor = pView.color
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
        txtColorHexCode.text = txtColorHex
//        print(txtColorHexCode.text?.characters.count ?? 5)
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        customizeableTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func cancelDatePicker(_ sender: AnyObject) {
        datePickerBckView.isHidden = true
        datePicker.isHidden = true
        doneDatePicker.isHidden = true
    }
    
    @IBAction func customizeText(_ sender: UIButton) {
        print(sender.tag)
        if sender.tag == 10 {
            customizeableTextField.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = true
            changeFontSizeBtn.isSelected = false
            changeFontColorBtn.isSelected = false
            
            fontView.isHidden = false
            fontListTableView.isHidden = true
            colorPickerView.isHidden = true
        }
        if sender.tag == 20 {
            customizeableTextField.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = false
            changeFontSizeBtn.isSelected = true
            changeFontColorBtn.isSelected = false
            
            fontView.isHidden = true
            fontListTableView.isHidden = false
            colorPickerView.isHidden = true
        }
        if sender.tag == 30 {
            customizeableTextField.resignFirstResponder()
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = false
            changeFontSizeBtn.isSelected = false
            changeFontColorBtn.isSelected = true
            
            fontView.isHidden = true
            fontListTableView.isHidden = true
            colorPickerView.isHidden = false
        }
    }
}
    
