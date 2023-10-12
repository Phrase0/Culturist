//
//  UIView.swift
//  CMHUD
//
//  Created by incetro on 5/21/21.
//

import UIKit

// MARK: - UIView

extension UIView {

    func smoothlyRoundCourners(
        _ corners: UIRectCorner = .allCorners,
        radius: CGFloat
    ) {
        let roundPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundPath.cgPath
        layer.mask = maskLayer
    }

    func subview(withId accessibilityIdentifier: String) -> UIView? {
        subviews.first { $0.accessibilityIdentifier == accessibilityIdentifier }
    }
}
