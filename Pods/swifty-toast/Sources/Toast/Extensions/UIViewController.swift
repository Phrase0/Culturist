//
//  UIViewController.swift
//  Toast
//
//  Created by incetro on 5/11/21.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - UIViewController

extension UIViewController {

    func toast(_ smartToastViewController: ToastViewController) {
        smartToastViewController.transDelegate = ToastTransitioningDelegate(
            toast: smartToastViewController.toast,
            size: smartToastViewController.preferredContentSize
        )
        smartToastViewController.transitioningDelegate = smartToastViewController.transDelegate
        smartToastViewController.modalPresentationStyle = .custom
        smartToastViewController.view.clipsToBounds = true
        smartToastViewController.view.roundCourners(radius: Constants.cornerRadius)
        present(smartToastViewController, animated: true)
    }
}
