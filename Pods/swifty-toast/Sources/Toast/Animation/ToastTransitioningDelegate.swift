//
//  ToastTransitioningDelegate.swift
//  Toast
//
//  Created by incetro on 5/11/2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - ToastTransitioningDelegate

final class ToastTransitioningDelegate: NSObject {

    // MARK: - Properties

    /// Current Toast instance
    private let toast: Toast

    /// Current toast size
    private let size: CGSize

    /// ToastAnimator instance
    let animator: ToastAnimator

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - toast: current Toast instance
    ///   - size: current toast size
    init(toast: Toast, size: CGSize) {
        self.toast = toast
        self.size = size
        self.animator = ToastAnimator(duration: 0.4, toast: toast, size: size)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ToastTransitioningDelegate: UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ToastPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            toast: toast,
            size: size
        )
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = true
        return animator
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
}
