//
//  Stack.swift
//  Layout
//
//  Created by Alexander Lezya on 21.01.2021.
//

import UIKit

// MARK: - Stack

public extension Array where Element: UIView {

    /// Place current views in the given view as vertical stack
    ///
    /// - Parameters:
    ///   - view: Target view
    ///   - spacing: Current views' spacing
    func verticalStack(
        in view: UIView,
        spacing: CGFloat = 0,
        pinToEdgesWithSpacing: Bool = true
    ) {

        forEach {
            view.addSubview($0)
            $0.prepareForAutolayout()
            $0.left.connect(to: view.left)
            $0.right.connect(to: view.right)
        }

        first?.top.connect(to: view.top, withInset: pinToEdgesWithSpacing ? spacing : 0)
        last?.bottom.connect(to: view.bottom, withInset: pinToEdgesWithSpacing ? -spacing : 0)

        guard count > 1 else {
            return
        }

        for index in 0..<count - 1 {
            self[index].bottom.connect(to: self[index + 1].top, withInset: -spacing)
            self[index].height.equal(to: self[index + 1].height)
        }
    }

    /// Place current views in the given view as horizontal stack
    ///
    /// - Parameters:
    ///   - view: Target view
    ///   - spacing: Current views' spacing
    func horizontalStack(
        in view: UIView,
        spacing: CGFloat = 0,
        isFillEqually: Bool = false
    ) {

        forEach {
            view.addSubview($0)
            $0.prepareForAutolayout()
            $0.top.connect(to: view.top)
            $0.bottom.connect(to: view.bottom)
        }

        first?.left.connect(to: view.left, withInset: spacing)
        last?.right.connect(to: view.right, withInset: -spacing)

        guard count > 1 else {
            return
        }

        for index in 0..<count - 1 {
            self[index].right.connect(to: self[index + 1].left, withInset: -spacing)
            if isFillEqually {
                self[index].width.equal(to: self[index + 1].width)
            }
        }
    }
}

