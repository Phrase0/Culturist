//
//  RecommendCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit
import Gemini

class RecommendCollectionViewCell: GeminiCell {
    
    lazy var productBackView: UIView = {
        return UIView()
    }()
    
    lazy var productView: UIView = {
        return UIView()
    }()
    
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        setFont(productName: productTitle, size: 5)
        return productTitle
    }()
    
    lazy var productTime: UILabel = {
        let productTime = UILabel()
        setFont(productName: productTime, size: 5)
        return productTime
    }()
    
    lazy var productImage: UIImageView = {
        let productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        return productImage
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
        setShadowColor()
    }

    private func setFont(productName:UILabel, size: CGFloat) {
        productName.numberOfLines = 1
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: size) {
            productName.font = pingFangFont
        } else {
            productName.font = UIFont.systemFont(ofSize: size)
            print("no font type")
        }
        productName.textAlignment = .center
    }
    
    private func setupSubviews() {
        contentView.addSubview(productBackView)
        contentView.addSubview(productView)
        contentView.addSubview(productTitle)
        contentView.addSubview(productTime)
        contentView.addSubview(productImage)
    }
    
    private func setupConstraints() {
        
        productBackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        
        productView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalTo(productBackView).inset(4)
            
        }
        
        productTitle.snp.makeConstraints { make in
            make.centerX.equalTo(productImage)
            make.top.equalTo(productImage.snp.bottom).offset(20)
        }
        
        productTime.snp.makeConstraints { make in
            make.centerX.equalTo(productImage)
            make.top.equalTo(productTitle.snp.bottom).offset(4)
        }
        
        productImage.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(productView).inset(40)
            make.bottom.equalTo(productView).inset(70)
        }
    }
    
    private func setShadowColor() {
        productBackView.backgroundColor = .GR0
        // productBackView.backgroundColor = UIColor(red: 106/255, green: 111/255, blue: 76/255, alpha: 1)
        productView.backgroundColor = .B4
        productBackView.layer.shadowColor = UIColor.black.cgColor
        productBackView.layer.shadowOpacity = 0.4
        productBackView.layer.shadowOffset = CGSize(width: 4, height: 4)
        productBackView.layer.shadowRadius = 4
        productBackView.layer.masksToBounds = false
        productImage.clipsToBounds = true
    }
    
}
