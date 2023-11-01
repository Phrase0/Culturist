//
//  AnimationCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit
import Gemini

class AnimationCollectionViewCell: GeminiCell {

    lazy var animationView: UIView = {
        return UIView()
    }()
    
    lazy var animationImage: UIImageView = {
        return UIImageView()
    }()
    
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        productTitle.numberOfLines = 0
        productTitle.textColor = .white
        if let pingFangFont = UIFont(name: "PingFangTC-Medium", size: 20) {
            productTitle.font = pingFangFont
        } else {
            productTitle.font = UIFont.systemFont(ofSize: 20)
            print("no font type")
        }
        return productTitle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        contentView.addSubview(animationView)
        animationView.addSubview(animationImage)
        animationView.addSubview(productTitle)
    }
    
    private func setupConstraints() {
        animationView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(10)
            make.top.equalTo(contentView).inset(5)
            make.bottom.equalTo(contentView).inset(10)
        }
        animationView.layer.cornerRadius = 8
        animationView.clipsToBounds = true
        
        animationImage.snp.makeConstraints { make in
            make.trailing.equalTo(animationView).offset(-30)
            make.top.equalTo(animationView).offset(30)
            make.bottom.equalTo(animationView).offset(-30)
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
