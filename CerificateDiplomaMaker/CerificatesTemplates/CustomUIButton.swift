//
//  CustomUIButton.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/19/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {

    var btnData : AnyObject
    override init(frame: CGRect) {
        self.btnData = 0 as AnyObject
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
