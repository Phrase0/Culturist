//
//  ToastPresentationController.swift
//  Toast
//
//  Created by incetro on 5/11/2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - ToastPresentationController

final class ToastPresentationController: UIPresentationController {

    // MARK: - Properties

    /// Current Toast instance
    private let toast: Toast

    /// Current toast size
    private let size: CGSize

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - presentedViewController: presented view controller instance
    ///   - presentingViewController: presenting view controller instance
    ///   - toast: current Toast instance
    ///   - size: current toast size
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        toast: Toast,
        size: CGSize
    ) {
        self.toast = toast
        self.size = size
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }
    
    // MARK: - UIPresentationController
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {

        guard let containerView = containerView else { return }
        var containerInsets = containerView.safeAreaInsets

        if let tabBar = toast.source?.parent as? UITabBarController{
            containerInsets.bottom += tabBar.tabBar.frame.height
        }

        if containerInsets.bottom == 0 {
            containerInsets.bottom += Constants.prettyfierInset
        }
        containerInsets.top += Constants.prettyfierInset

        let yPosition: CGFloat
        switch toast.location {
        case .bottom:
            yPosition = containerView.frame.origin.y + containerView.frame.height - size.height - containerInsets.bottom
        case .top:
            yPosition = containerInsets.top
        }
        
        containerView.frame.origin = CGPoint(
            x: (containerView.frame.width - frameOfPresentedViewInContainerView.width) / 4,
            y: yPosition
        )
        containerView.frame.size = size
    }
    
    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        size
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let containerSize = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )
        let yPosition: CGFloat
        switch toast.location {
        case .bottom:
            yPosition = containerView.bounds.height - containerSize.height
        case .top:
            yPosition = 0
        }
        let toastSize = CGRect(
            x: containerView.center.x - (containerSize.width / 2),
            y: yPosition,
            width: containerSize.width,
            height: containerSize.height
        )
        return toastSize
    }
}
