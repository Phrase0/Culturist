//
//  LaunchScreenViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/3.
//

import UIKit
import Lottie
class LaunchScreenViewController: UIViewController {

    let width = UIScreen.main.bounds.width
    
    let animationView = LottieAnimationView(asset: "launchAnimation", bundle: .main)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .GR2
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        view.addSubview(animationView)
        animationView.play()
        setUpAutolayout()
    }
    
    func setUpAutolayout() {
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(width)
        }
    }
    
}
