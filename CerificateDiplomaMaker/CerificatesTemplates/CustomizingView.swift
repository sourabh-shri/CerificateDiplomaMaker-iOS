//
//  CustomizingView.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 12/15/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class CustomizingView: UIView {

    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var fontSizeTxtField: UITextField!
    @IBOutlet weak var fontStepper: UIStepper!
    @IBOutlet weak var fontListTableView: UITableView!
    
    var fontArray : NSMutableArray=[]
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPicker: SwiftHSVColorPicker!
    @IBOutlet weak var txtColorHexCode: UITextField!
    @IBOutlet weak var changeFontBtn: UIButton!
    @IBOutlet weak var changeFontSizeBtn: UIButton!
    @IBOutlet weak var changeFontColorBtn: UIButton!
    @IBOutlet weak var cancelBtnBackView: UIView!
    @IBOutlet weak var applyBtnBackView: UIView!
    var selectedCustomizeableTFOrTV : String!
    var selectedFontName = String()
    
//    var parentEditViewInstance = EditCertificateViewController()

    
    override func awakeFromNib() {
//        setFontListArray()
        
 //       cancelBtnBackView.layer.cornerRadius = 15
        cancelBtnBackView.layer.cornerRadius = 8
        cancelBtnBackView.layer.masksToBounds = true
    }
    
    
    @IBAction func customizeText(_ sender: UIButton) {
        print(sender.tag)
        if sender.tag == 10 {
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = true
            changeFontSizeBtn.isSelected = false
            changeFontColorBtn.isSelected = false
            fontListTableView.isHidden = false
            fontView.isHidden = true
            colorPickerView.isHidden = true
        }
        if sender.tag == 20 {
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = false
            changeFontSizeBtn.isSelected = true
            changeFontColorBtn.isSelected = false
            fontListTableView.isHidden = true
            fontView.isHidden = false
            colorPickerView.isHidden = true
        }
        if sender.tag == 30 {
            fontSizeTxtField.resignFirstResponder()
            txtColorHexCode.resignFirstResponder()
            changeFontBtn.isSelected = false
            changeFontSizeBtn.isSelected = false
            changeFontColorBtn.isSelected = true
            fontListTableView.isHidden = true
            fontView.isHidden = true
            colorPickerView.isHidden = false
        }
    }

    @IBAction func cancelBtnPressed(_ sender: UIButton){
        selectedCustomizeableTFOrTV = ""
        self.isHidden = true
    }
}
