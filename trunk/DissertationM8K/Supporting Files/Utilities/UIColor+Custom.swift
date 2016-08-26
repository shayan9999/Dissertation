/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `UIColor+Custom` method provides a generator method for a custom color.
*/

import UIKit

extension UIColor {
    
    /// - returns:  A nice blue color which suggests editability.
    static func editableBlueColor() -> UIColor {
        return UIColor(red:0/255.0, green:122/255.0, blue:255/255.0, alpha:1.0)
    }
    
    static func colorFromHex(hexString: String, alpha: CGFloat = 1) -> UIColor {
        //checking if hex has 7 characters or not including '#'
        if hexString.characters.count < 7 {
            return UIColor.whiteColor()
        }
        //string by removing hash
        let hexStringWithoutHash = hexString.substringFromIndex(hexString.startIndex.advancedBy(1))
        
        //I am extracting three parts of hex color Red (first 2 characters), Green (middle 2 characters), Blue (last two characters)
        let eachColor = [
            hexStringWithoutHash.substringWithRange(hexStringWithoutHash.startIndex...hexStringWithoutHash.startIndex.advancedBy(1)),
            hexStringWithoutHash.substringWithRange(hexStringWithoutHash.startIndex.advancedBy(2)...hexStringWithoutHash.startIndex.advancedBy(3)),
            hexStringWithoutHash.substringWithRange(hexStringWithoutHash.startIndex.advancedBy(4)...hexStringWithoutHash.startIndex.advancedBy(5))]
        
        let hexForEach = eachColor.map {CGFloat(Int($0, radix: 16) ?? 0)} //radix is base of numeric system you want to convert to, Hexadecimal has base 16
        
        //return the color by making color
        return UIColor(red: hexForEach[0] / 255, green: hexForEach[1] / 255, blue: hexForEach[2] / 255, alpha: alpha)
    }
}