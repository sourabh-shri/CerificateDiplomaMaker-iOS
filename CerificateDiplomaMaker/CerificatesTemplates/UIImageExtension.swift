//
//  UIImageExtension.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/5/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit
extension UIImage{
    class func renderUIViewToImage(_ viewToBeRendered:UIView?) -> UIImage
    {
//        let savedContentOffSet = viewToBeRendered?.contentOffset
//        let savedFrame = viewToBeRendered?.frame
//        
//        viewToBeRendered?.contentSize.width = (viewToBeRendered?.contentSize.width)!
//        viewToBeRendered?.contentSize.height = (viewToBeRendered?.contentSize.height)! - 70
//        
//        UIGraphicsBeginImageContext((viewToBeRendered?.contentSize)!)
//        
//        viewToBeRendered?.contentOffset = CGPointZero
//        
//        viewToBeRendered?.frame = CGRectMake(0, 0, (viewToBeRendered?.contentSize.width)!,(viewToBeRendered?.contentSize.height)!)
//        
//        viewToBeRendered?.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        viewToBeRendered?.contentOffset = savedContentOffSet!
//        viewToBeRendered?.frame = savedFrame!
//        UIGraphicsEndImageContext();
//        
//        return image
        
        UIGraphicsBeginImageContextWithOptions(viewToBeRendered!.bounds.size, viewToBeRendered!.isOpaque, 0.0)
        
        viewToBeRendered?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    func isEqualToImage(_ image: UIImage) -> Bool {
        let data1: Data = self.pngData()!
        let data2: Data = image.pngData()!
        return (data1 == data2)
    }
}
