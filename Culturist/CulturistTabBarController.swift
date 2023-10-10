//
//  CulturistTabBarController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/22.
//

import UIKit

class CulturistTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.GR0
        self.delegate = self
    }
    
    // touch feedback
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
}
