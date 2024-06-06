//
//  ColorConverter.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/4/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

// convertHexToUIColor
func hexStringToUIColor (_ hex:String) -> UIColor {
////    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercased()
//    
//    var cString : String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
//
//    
//    if (cString.hasPrefix("#")) {
//        cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
//    }
//    
//    if ((cString.characters.count) != 6) {
//        return UIColor.gray
//    }
//    
//    var rgbValue:UInt32 = 0
//    Scanner(string: cString).scanHexInt32(&rgbValue)
//    return UIColor(
//        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//        alpha: CGFloat(1.0)
//    )
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat( rgbValue & 0x000000FF       )
    )
}


func hexStringFromUIColor(_ color:UIColor) ->String {
//    let components = color.cgColor.components
//    let red = Float((components?[0])!)
//    let green = Float((components?[1])!)
//    let blue = Float((components?[2])!)

//    var r:CGFloat = 0
//    var g:CGFloat = 0
//    var b:CGFloat = 0
//    var a:CGFloat = 0
//    
//    color.getRed(&r, green: &g, blue: &b, alpha: &a)
//    
//    let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
//
//    print(r)
//    print(g)
//    print(b)
//    print(NSString(format:"#%06x", rgb))
    
//    return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
//    return NSString(format:"#%06x", rgb) as String
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    _ = CGFloat(255.999999)
    
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return "none"
    }
    
    if alpha == 1.0 {
//        print( String(
//            format: "#%02X%02X%02X",
//            Int(red * multiplier),
//            Int(green * multiplier),
//            Int(blue * multiplier)))
        
//        return String(
//            format: "#%02lX%02lX%02lX",
//            Int(red * multiplier),
//            Int(green * multiplier),
//            Int(blue * multiplier)
//        )
        print(String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255)))
         return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        
        
      
    }
    else {
//        print( String(
//            format: "#%02X%02X%02X%02X",
//            Int(red * multiplier),
//            Int(green * multiplier),
//            Int(blue * multiplier),
//            Int(alpha * multiplier)))
        
//        return String(
//            format: "#%02lX%02lX%02lX%02lX",
//            Int(red * multiplier),
//            Int(green * multiplier),
//            Int(blue * multiplier),
//            Int(alpha * multiplier)
//        )
        
        print(String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255)))
         return String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
    }
}
