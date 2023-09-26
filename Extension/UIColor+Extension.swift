//
//  UIColor+Extension.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/21.
//

import UIKit

private enum STColor: String {
    // swiftlint:disable identifier_name
    case B1
    case B2
    case B3
    case B4
    case B5
    case B6
    case BL1
    case GR1
    case GR2
    case GR3
    case R1
    case R2
    case R3
    // swiftlint:enable identifier_name
}

extension UIColor {

    // swiftlint:disable identifier_name
    static let B1 = STColor(.B1)
    static let B2 = STColor(.B2)
    static let B3 = STColor(.B3)
    static let B4 = STColor(.B4)
    static let BL1 = STColor(.BL1)
    static let GR1 = STColor(.GR1)
    static let GR2 = STColor(.GR2)
    static let GR3 = STColor(.GR3)
    static let R1 = STColor(.R1)
    static let R2 = STColor(.R2)
    static let R3 = STColor(.R3)
    // swiftlint:enable identifier_name
    
    private static func STColor(_ color: STColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
