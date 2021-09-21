//
//  UIColor+Extensions.swift
//  Airbus Type Rating Study
//
//  Created by Nazmi Yavuz on 3.05.2021.
//

import UIKit

extension UIColor {
        
    static let mainPink = UIColor.setRgbColor(red: 221, green: 94, blue: 86)
    
    static let mainBlue = UIColor.setRgbColor(red: 55, green: 120, blue: 250)
    
    static let directionsGreen = UIColor.setRgbColor(red: 76, green: 217, blue: 100)
    
    static func setRgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
//    static func mainPink() -> UIColor {
//        return UIColor.rgb(red: 221, green: 94, blue: 86)
//    }
    
//    static func mainBlue() -> UIColor {
//        return UIColor.rgb(red: 55, green: 120, blue: 250)
//    }
    
//    static func directionsGreen() -> UIColor {
//        return UIColor.rgb(red: 76, green: 217, blue: 100)
//    }
}
