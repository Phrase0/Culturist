//
//  CulturistTabBarController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/22.
//

import UIKit

class CulturistTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.GR0
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: -2, right: -2)
        self.delegate = self
        feedbackGenerator.prepare()
    }
    
    // touch feedback
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        feedbackGenerator.impactOccurred()
    }
    
}
