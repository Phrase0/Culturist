//
//  ActivityIndicatorData.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/30.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class ActivityIndicatorManager: UIViewController {
    
    static let shared = ActivityIndicatorManager()
    
    override func viewDidLoad() {
    }
    
    func startAnimation() {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR2, padding: 0)
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        loading.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            loading.stopAnimating()
        }
    }
    
}
