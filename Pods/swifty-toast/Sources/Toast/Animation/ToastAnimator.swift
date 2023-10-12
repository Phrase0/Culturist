//
//  ToastAnimator.swift
//  Toast
//
//  Created by incetro on 5/11/2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - ToastAnimator

final class ToastAnimator: NSObject {

    // MARK: - Properties

    var presenting: Bool?

    /// Current Toast instance
    private let toast: Toast

    /// Animation duration
    private let duration: TimeInterval

    /// Current toast size
    private let size: CGSize

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - duration: animation duration
    ///   - toast: current Toast instance
    ///   - size: current toast size
    init(duration: TimeInterval, toast: Toast, size: CGSize) {
        self.duration = duration
        self.toast = toast
        self.size = size
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ToastAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let presenting = presenting else { return }

        let key: UITransitionContextViewControllerKey = presenting ? .to : .from
        let controller = transitionContext.viewController(forKey: key)!
        
        if presenting {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        
        switch presenting ? toast.presentingDirection : toast.dismissingDirection {
        case .vertical:
            dismissedFrame.origin.y = (toast.location == .bottom) ? controller.view.frame.height + 60 : -size.height - 60
        case .left:
            dismissedFrame.origin.x = -controller.view.frame.width * 2
        case .right:
            dismissedFrame.origin.x = controller.view.frame.width * 2
        }
        
        let initialFrame = presenting ? dismissedFrame : presentedFrame
        let finalFrame = presenting ? presentedFrame : dismissedFrame
        let animationOption: UIView.AnimationOptions = presenting ? .curveEaseOut : .curveEaseIn
        
        controller.view.alpha = presenting ? 0 : 1
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.65,
            options: animationOption,
            animations: {
                controller.view.frame = finalFrame
                controller.view.alpha = presenting ? 1 : 0
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}
