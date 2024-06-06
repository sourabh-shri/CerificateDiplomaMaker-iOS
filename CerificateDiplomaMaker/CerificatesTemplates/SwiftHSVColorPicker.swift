//
//  SwiftHSVColorPicker.swift
//  SwiftHSVColorPicker
//
//  Created by johankasperi on 2015-08-20.
//

import UIKit

protocol SwiftHSVColorPickerDelegate : class {
    func setTextColor(_ pView:SwiftHSVColorPicker) 
}


open class SwiftHSVColorPicker: UIView, ColorWheelDelegate, BrightnessViewDelegate {

    var colorWheel : ColorWheel!
    var brightnessView: BrightnessView!
    var selectedColorView: SelectedColorView!
    var color: UIColor!
    var hue: CGFloat = 1.0
    var saturation: CGFloat = 1.0
    var brightness: CGFloat = 1.0
    var i = 0
    
    weak var delegate: SwiftHSVColorPickerDelegate?


    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open func setViewColor(_ color: UIColor) {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if (!ok) {
            print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
        }
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.color = color
        setup()
    }
    
    func setup() {
        // Remove all subviews
        let views = self.subviews
        for view in views {
            view.removeFromSuperview()
        }
        
        let selectedColorViewHeight : CGFloat = 44.0
        let brightnessViewHeight: CGFloat = 26.0
        
        // let color wheel get the maximum size that is not overflow from the frame for both width and height
//        let colorWheelSize = min(self.bounds.width, self.bounds.height - selectedColorViewHeight - brightnessViewHeight)
        
        
    _ = 86 

        // let the all the subviews stay in the middle of universe horizontally
//        let centeredX = (self.bounds.width - colorWheelSize) / 2.0
        
        // Init SelectedColorView subview
//        selectedColorView = SelectedColorView(frame: CGRect(x: centeredX, y:0, width: colorWheelSize, height: selectedColorViewHeight), color: self.color)
        
        
        if UIScreen.main.bounds.size.width == 768.0 {
            selectedColorView = SelectedColorView(frame: CGRect(x: 390 , y:0, width: 207, height: 47), color: self.color)
        }
        else {
            selectedColorView = SelectedColorView(frame: CGRect(x: 194 , y:-10, width: 97, height: 30), color: self.color)
        }

        // Add selectedColorView as a subview of this view
        self.addSubview(selectedColorView)
        
        // Init new ColorWheel subview
//        colorWheel = ColorWheel(frame: CGRect(x: 40, y: Int(selectedColorView.frame.maxY), width: 286 , height: 286), color: self.color)
        if UIScreen.main.bounds.size.width == 768.0 {
            colorWheel = ColorWheel(frame: CGRect(x: 20, y: 40, width: 350 , height: 350), color: self.color)
            // Init new BrightnessView subview
            brightnessView = BrightnessView(frame: CGRect(x: 400, y: (colorWheel.frame.origin.y+350)/2, width: 230.0, height: 80.0), color: self.color)
        }
        else {
            colorWheel = ColorWheel(frame: CGRect(x: -10, y:-15, width: 166 , height: 166), color: self.color)
            // Init new BrightnessView subview
            brightnessView = BrightnessView(frame: CGRect(x: 170, y: (colorWheel.frame.origin.y+150)/2, width: 130, height: brightnessViewHeight), color: self.color)
        }
        colorWheel.delegate = self
        // Add colorWheel as a subview of this view
        self.addSubview(colorWheel)
        brightnessView.delegate = self
        // Add brightnessView as a subview of this view
        self.addSubview(brightnessView)
    }
    
    func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        brightnessView.setViewColor(self.color)
        selectedColorView.setViewColor(self.color)
        delegate?.setTextColor(self)
    }
    
    func brightnessSelected(_ brightness: CGFloat) {
        self.brightness = brightness
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        colorWheel.setViewBrightness(brightness)
        selectedColorView.setViewColor(self.color)
        delegate?.setTextColor(self)
    }
}
