//
//  CustomTextField.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 12/1/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    var txtFData : AnyObject
    override init(frame: CGRect) {
        self.txtFData = 0 as AnyObject
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
