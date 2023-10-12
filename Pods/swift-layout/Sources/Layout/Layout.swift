//
//  Layout.swift
//  Layout
//
//  Created by Alexander Lezya on 21.01.2021.
//

import UIKit

// MARK: - UIView

public extension UIView {

    // MARK: - Properties

    /// Width constraint
    var width: DimensionConstraint {
        DimensionConstraint(constraint: widthAnchor)
    }

    /// Height constraint
    var height: DimensionConstraint {
        DimensionConstraint(constraint: heightAnchor)
    }

    /// Left constraint
    var left: Constraint<NSLayoutXAxisAnchor> {
        Constraint(constraint: leadingAnchor)
    }

    /// Right constraint
    var right: Constraint<NSLayoutXAxisAnchor> {
        Constraint(constraint: trailingAnchor)
    }

    /// Top constraint
    var top: Constraint<NSLayoutYAxisAnchor> {
        Constraint(constraint: topAnchor)
    }

    /// Bottom constraint
    var bottom: Constraint<NSLayoutYAxisAnchor> {
        Constraint(constraint: bottomAnchor)
    }

    /// Center on X axis constraint
    var centerX: Constraint<NSLayoutXAxisAnchor> {
        Constraint(constraint: centerXAnchor)
    }

    /// Center on Y axis constraint
    var centerY: Constraint<NSLayoutYAxisAnchor> {
        Constraint(constraint: centerYAnchor)
    }

    /// Top left anchor constraint
    var topLeftAngle: ConstraintAngle {
        ConstraintAngle(first: leadingAnchor, second: topAnchor)
    }

    /// Top right anchor constraint
    var topRightAngle: ConstraintAngle {
        ConstraintAngle(first: trailingAnchor, second: topAnchor)
    }

    /// Bottom left anchor constraint
    var bottomLeftAngle: ConstraintAngle {
        ConstraintAngle(first: leadingAnchor, second: bottomAnchor)
    }

    /// Bottom right angle constraint
    var bottomRightAngle: ConstraintAngle {
        ConstraintAngle(first: trailingAnchor, second: bottomAnchor)
    }

    // MARK: - Useful methods

    /// Prepare view for auto layout
    /// - Returns: Current view
    @discardableResult func prepareForAutolayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    /// Set view size through width and height
    /// - Parameters:
    ///   - width: View width
    ///   - height: View height
    /// - Returns: Current view
    @discardableResult func size(width: CGFloat, height: CGFloat) -> Self {
        self.width(width)
        self.height(height)
        return self
    }

    /// Set view size through width and height
    /// - Parameters:
    ///   - width: View width
    ///   - height: View height
    /// - Returns: Current view
    @discardableResult func size(_ size: CGFloat) -> Self {
        self.width(size)
        self.height(size)
        return self
    }

    /// Set view size through CGSize value
    /// - Parameters:
    ///   - size: CGSize value
    /// - Returns: Current view
    @discardableResult func size(_ size: CGSize) -> Self {
        self.width(size.width)
        self.height(size.height)
        return self
    }

    /// Set view size as size of another view
    /// - Parameters:
    ///   - view: View for emulating
    ///   - multiplier: Constraints multiplier
    /// - Returns: Current view
    @discardableResult func size(as view: UIView, multiplier: CGFloat = 1) -> Self {
        width(equalTo: view.width, multiplier: multiplier)
        height(equalTo: view.height, multiplier: multiplier)
        return self
    }

    /// Set view width
    /// - Parameter const: width value
    /// - Returns: Current view
    @discardableResult func width(_ const: CGFloat) -> Self {
        width.equal(to: const)
        return self
    }

    /// Set view height
    /// - Parameter const: height value
    /// - Returns: Current view
    @discardableResult func height(_ const: CGFloat) -> Self {
        height.equal(to: const)
        return self
    }

    /// Set view width through another constraint
    /// - Parameters:
    ///   - other: constraint for emulating
    ///   - multiplier: constraint's multiplier
    /// - Returns: Current view
    @discardableResult func width(equalTo other: DimensionConstraint, multiplier: CGFloat = 1) -> Self {
        width.equal(to: other, multiplier: multiplier)
        return self
    }

    /// Set view height through another constraint
    /// - Parameters:
    ///   - other: constraint for emulating
    ///   - multiplier: constraint's multiplier
    /// - Returns: Current view
    @discardableResult func height(equalTo other: DimensionConstraint, multiplier: CGFloat = 1) -> Self {
        height.equal(to: other, multiplier: multiplier)
        return self
    }

    /// Connect current bottom to other bottom
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func bottom(to other: Constraint<NSLayoutYAxisAnchor>) -> Self {
        bottom.connect(to: other)
        return self
    }

    /// Connect current top to other top
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func top(to other: Constraint<NSLayoutYAxisAnchor>) -> Self {
        top.connect(to: other)
        return self
    }

    /// Connect current left to other left
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func left(to other: Constraint<NSLayoutXAxisAnchor>) -> Self {
        left.connect(to: other)
        return self
    }

    /// Connect current right to other right
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func right(to other: Constraint<NSLayoutXAxisAnchor>) -> Self {
        right.connect(to: other)
        return self
    }

    /// Connect current bottom to other bottom
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func bottom(to other: MetaConstraint<NSLayoutYAxisAnchor>) -> Self {
        bottom.connect(to: other)
        return self
    }

    /// Connect current top to other top
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func top(to other: MetaConstraint<NSLayoutYAxisAnchor>) -> Self {
        top.connect(to: other)
        return self
    }

    /// Connect current left to other left
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func left(to other: MetaConstraint<NSLayoutXAxisAnchor>) -> Self {
        left.connect(to: other)
        return self
    }

    /// Connect current right to other right
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func right(to other: MetaConstraint<NSLayoutXAxisAnchor>) -> Self {
        right.connect(to: other)
        return self
    }

    /// Connect current centerX to other centerX
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func centerX(to other: Constraint<NSLayoutXAxisAnchor>) -> Self {
        centerX.connect(to: other)
        return self
    }

    /// Connect current centerY to other centerY
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func centerY(to other: Constraint<NSLayoutYAxisAnchor>) -> Self {
        centerY.connect(to: other)
        return self
    }

    /// Connect current centerX to other centerX
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func centerX(to other: MetaConstraint<NSLayoutXAxisAnchor>) -> Self {
        centerX.connect(to: other)
        return self
    }

    /// Connect current centerY to other centerY
    /// - Parameter other: constraint for connection
    /// - Returns: Current view
    @discardableResult func centerY(to other: MetaConstraint<NSLayoutYAxisAnchor>) -> Self {
        centerY.connect(to: other)
        return self
    }

    /// Connect current center to other center
    /// - Parameter view: View with target center
    /// - Returns: Current view
    @discardableResult func center(in view: UIView) -> Self {
        centerX.connect(to: view.centerX)
        centerY.connect(to: view.centerY)
        return self
    }

    /// Pin current view to other view with edges instets
    /// - Parameters:
    ///   - view: View for connection
    ///   - left: left inset
    ///   - right: right inset
    ///   - top: top inset
    ///   - bottom: bottom inset
    /// - Returns: Current view
    @discardableResult func pinEdges(
        to view: UIView,
        left: CGFloat = 0,
        right: CGFloat = 0,
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) -> Self {
        self.left.connect(to: view.left, withInset: left)
        self.right.connect(to: view.right, withInset: -right)
        self.top.connect(to: view.top, withInset: top)
        self.bottom.connect(to: view.bottom, withInset: -bottom)
        return self
    }

    /// Pin current view's edges view to subview's edges
    /// - Parameters:
    ///   - left: left inset
    ///   - right: right inset
    ///   - top: top inset
    ///   - bottom: bottom inset
    /// - Returns: Current view
    @discardableResult func pinEdgesToSuperview(
        left: CGFloat = 0,
        right: CGFloat = 0,
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) -> Self {
        guard let superview = superview else {
            fatalError("Cennot obtain superview for layouting")
        }
        pinEdges(to: superview, left: left, right: right, top: top, bottom: bottom)
        return self
    }

    /// Pin current view to other view with some insets (to left, right, top and bottom)
    /// - Parameters:
    ///   - view: Target view
    ///   - inset: [left, right, top, bottom]'s inset
    /// - Returns: Current view
    @discardableResult func pin(to view: UIView, withInset inset: CGFloat = 0) -> Self {
        left.connect(to: view.left, withInset: inset)
        right.connect(to: view.right, withInset: -inset)
        top.connect(to: view.top, withInset: inset)
        bottom.connect(to: view.bottom, withInset: -inset)
        return self
    }

    /// Pin current view to superview with some insets (to left, right, top and bottom)
    /// - Parameter inset: [left, right, top, bottom]'s inset
    /// - Returns: Current view
    @discardableResult func pinToSuperview(withInset inset: CGFloat = 0) -> Self {
        guard let superview = superview else {
            fatalError("Cannot obtain superview for layouting")
        }
        pin(to: superview, withInset: inset)
        return self
    }

    /// View's sides
    /// - top: top side
    /// - left: left side
    /// - right: right side
    /// - bottom: bottom side
    enum PinnedSide {
        case top
        case left
        case right
        case bottom
    }

    /// Pin current view to other view excluding some side and using inset
    /// - Parameters:
    ///   - view: Target view
    ///   - side: Side which should be excluded
    ///   - inset: [left, right, top, bottom]'s inset
    /// - Returns: Current view
    @discardableResult func pin(
        to view: UIView,
        excludingSide side: PinnedSide,
        usingInset inset: CGFloat = 0
    ) -> Self {
        switch side {
        case .top:
            pin(to: view, withSides: .left, .right, .bottom, andInset: inset)
        case .left:
            pin(to: view, withSides: .top, .right, .bottom, andInset: inset)
        case .right:
            pin(to: view, withSides: .top, .left, .bottom, andInset: inset)
        case .bottom:
            pin(to: view, withSides: .top, .left, .right, andInset: inset)
        }
        return self
    }

    /// Pin current view to superview excluding some side and using inset
    /// - Parameters:
    ///   - side: Side which should be excluded
    ///   - inset: [left, right, top, bottom]'s inset
    /// - Returns: Current view
    @discardableResult func pinToSuperview(excluding side: PinnedSide, usingInset inset: CGFloat = 0) -> Self {
        guard let superview = superview else {
            fatalError("There is no superview or sides")
        }
        return pin(to: superview, excludingSide: side, usingInset: inset)
    }

    /// Pin current view to superview using some sides and inset
    /// - Parameters:
    ///   - sides: Sides which should be pinned
    ///   - inset: Sides inset
    /// - Returns: Current view
    @discardableResult func pinToSuperview(withSides sides: PinnedSide..., andInset inset: CGFloat = 0) -> Self {
        guard let superview = superview, !sides.isEmpty else {
            fatalError("There is no superview or sides")
        }
        sides.forEach { side in
            switch side {
            case .top:
                top.connect(to: superview.top, withInset: inset)
            case .right:
                right.connect(to: superview.right, withInset: -inset)
            case .left:
                left.connect(to: superview.left, withInset: inset)
            case .bottom:
                bottom.connect(to: superview.bottom, withInset: -inset)
            }
        }
        return self
    }

    /// Pin current view to other view using some sides and inset
    /// - Parameters:
    ///   - view: Target view
    ///   - sides: Sides which should be pinned
    ///   - inset: Sides inset
    /// - Returns: Current view
    @discardableResult func pin(to view: UIView, withSides sides: PinnedSide..., andInset inset: CGFloat = 0) -> Self {
        sides.forEach { side in
            switch side {
            case .top:
                top.connect(to: view.top, withInset: inset)
            case .right:
                right.connect(to: view.right, withInset: -inset)
            case .left:
                left.connect(to: view.left, withInset: inset)
            case .bottom:
                bottom.connect(to: view.bottom, withInset: -inset)
            }
        }
        return self
    }

    /// Full pin view to other view using all sides with insets
    /// - Parameters:
    ///   - view: Target view
    ///   - insets: Sides insets
    /// - Returns: Current view
    @discardableResult func fullPin(to view: UIView, withInsets insets: UIEdgeInsets) -> Self {
        top.connect(to: view.top, withInset: insets.top)
        left.connect(to: view.left, withInset: insets.left)
        right.connect(to: view.right, withInset: -insets.right)
        bottom.connect(to: view.bottom, withInset: -insets.bottom)
        return self
    }

    /// Full pin view to superview using all sides with insets
    /// - Parameters:
    ///   - insets: Sides insets
    /// - Returns: Current view
    @discardableResult func fullPinToSuperview(withInsets insets: UIEdgeInsets) -> Self {
        guard let superview = superview else {
            fatalError("There is no superview or sides")
        }
        return fullPin(to: superview, withInsets: insets)
    }

    /// Pin view to other view using only those sides where the indent is not zero
    /// - Parameters:
    ///   - view: Target view
    ///   - insets: Sides insets
    /// - Returns: Current view
    @discardableResult func safePin(to view: UIView, withInsets insets: UIEdgeInsets) -> Self {
        if insets.top != 0 {
            top.connect(to: view.top, withInset: insets.top)
        }
        if insets.left != 0 {
            left.connect(to: view.left, withInset: insets.left)
        }
        if insets.right != 0 {
            right.connect(to: view.right, withInset: -insets.right)
        }
        if insets.bottom != 0 {
            bottom.connect(to: view.bottom, withInset: -insets.bottom)
        }
        return self
    }

    /// Pin view to superview using only those sides where the indent is not zero
    /// - Parameters:
    ///   - insets: Sides insets
    /// - Returns: Current view
    @discardableResult func safePinToSuperview(withInsets insets: UIEdgeInsets) -> Self {
        guard let superview = superview else {
            fatalError("There is no superview or sides")
        }
        return safePin(to: superview, withInsets: insets)
    }
}

// MARK: - UIViewController

public extension UIViewController {

    var safeTopAnchor: NSLayoutYAxisAnchor {
        view.safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        view.safeAreaLayoutGuide.bottomAnchor
    }

    var safeTop: Constraint<NSLayoutYAxisAnchor> {
        Constraint<NSLayoutYAxisAnchor>(constraint: safeTopAnchor)
    }

    var safeBottom: Constraint<NSLayoutYAxisAnchor> {
        Constraint<NSLayoutYAxisAnchor>(constraint: safeBottomAnchor)
    }
}
