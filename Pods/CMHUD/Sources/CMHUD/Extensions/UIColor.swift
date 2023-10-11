//
//  UIColor.swift
//  CMHUD
//
//  Created by incetro on 5/21/21.
//

import UIKit

// MARK: - UIColor

extension UIColor {

    /// Creates an UIColor from HEX String in "#363636" format
    ///
    /// - Parameter hexString: HEX String in "#363636" format
    convenience init(hexString: String) {

        let hexString = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    /// Creates an UIColor Object based on provided RGB value in integer
    ///
    /// - Parameters:
    ///   - red: Red Value in integer (0..255)
    ///   - green: Green Value in integer (0..255)
    ///   - blue: Blue Value in integer (0..255)
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
