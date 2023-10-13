//
//  AnimationCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit

class AnimationCollectionViewCell: UICollectionViewCell {
    
    // let width = UIScreen.main.bounds.width
    
    lazy var animationView: UIView = {
        let animationView = UIView()
        return animationView
    }()
    
    lazy var animationImage: UIImageView = {
        let animationImage = UIImageView()
        return animationImage
    }()
    
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        productTitle.numberOfLines = 0
        if let pingFangFont = UIFont(name: "PingFangTC-Medium", size: 18) {
            productTitle.font = pingFangFont
        } else {
            productTitle.font = UIFont.systemFont(ofSize: 18)
            print("no font type")
        }
        return productTitle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        contentView.addSubview(animationView)
        animationView.addSubview(animationImage)
        animationView.addSubview(productTitle)
    }
    
    func setupConstraints() {
        animationView.backgroundColor = UIColor.Color1
        animationView.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalTo(contentView)
        }
        
        animationImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()  // 垂直居中
            make.trailing.equalTo(animationView).offset(-30)  // 距离 animationView.trailing 30
            make.top.equalTo(animationView).offset(40)  // 距离 animationView.top 30
            make.bottom.equalTo(animationView).offset(-40)  // 距离 animationView.bottom 30
            make.width.equalTo(animationImage.snp.height)  // 1:1 宽高比
        }
    }
    
}
