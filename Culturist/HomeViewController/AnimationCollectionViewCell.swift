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
        productTitle.textColor = .white
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
            make.leading.bottom.trailing.equalTo(contentView).inset(16)
            make.top.equalTo(contentView)
        }
        animationView.layer.cornerRadius = 8
        animationView.clipsToBounds = true
        
        animationImage.snp.makeConstraints { make in
            make.trailing.equalTo(animationView).offset(-30)
            make.top.equalTo(animationView).offset(40)
            make.bottom.equalTo(animationView).offset(-40)
            make.width.equalTo(animationImage.snp.height)
        }
        animationImage.contentMode = .scaleAspectFill
        animationImage.clipsToBounds = true
        
        productTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(animationView).offset(30)
            make.trailing.equalTo(animationImage.snp.leading).offset(-20)
        }
    }
}
