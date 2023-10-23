//
//  UIImage+Extension.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/21.
//

import UIKit

// swiftlint:disable identifier_name
enum ImageAsset: String {

    // Profile tab - Tab
    case Icons_30px_Home_Normal
    case Icons_30px_Home_Selected
    case Icons_30px_Profile_Normal
    case Icons_30px_Profile_Selected
    case Icons_30px_Recommendation_Normal
    case Icons_30px_Recommendation_Selected
    case Icons_30px_BookMark_Normal
    case Icons_30px_BookMark_Selected
    
    // page
    case Icons_24px_Notification
    case Icons_24px_BookMark_Normal
    case Icons_24px_BookMark_Selected_Color
    case Icons_24px_Web
    
    case Icons_18px_Book
    case Icons_18px_Coffee
    // close and back
    case Icons_36px_Close_Black
    case Icons_36px_Back_Black
    
    case culturist_logo_green_navTitle
}

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
