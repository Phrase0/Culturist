//
//  String.swift
//  Toast
//
//  Created by incetro on 5/11/21.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - String

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
