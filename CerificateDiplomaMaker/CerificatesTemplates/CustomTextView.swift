//
//  CustomTextView.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 12/2/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {

    var txtVData : AnyObject
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        self.txtVData = 0 as AnyObject
        super.init(frame: frame, textContainer:textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
