//
//  RoundButton.swift
//  DemoIBDesignableIBInspectable
//
//  Created by Bhisma on 11/22/16.
//  Copyright © 2016 Surya. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var boderColor : UIColor? {
        didSet {
            layer.borderColor = boderColor!.cgColor
            layer.masksToBounds = true
        }
    }
}
