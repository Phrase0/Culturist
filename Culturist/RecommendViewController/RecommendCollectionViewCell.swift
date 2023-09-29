//
//  RecommendCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit
import Gemini

class RecommendCollectionViewCell: GeminiCell {

    lazy var productView: UIView = {
        let productView = UIView()
        return productView
    }()
 
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        productTitle.numberOfLines = 2
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 16) {
            productTitle.font = pingFangFont
        } else {
            productTitle.font = UIFont.systemFont(ofSize: 16)
            print("no font type")
        }
        return productTitle
    }()

    
    lazy var productImage: UIImageView = {
        let productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        return productImage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setShadowColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupConstraints()
        setShadowColor()
    }
    

    
    private func setupSubviews() {
        contentView.addSubview(productView)
        contentView.addSubview(productTitle)
        contentView.addSubview(productImage)
    }
    
    private func setupConstraints() {
        
        productView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        
        productTitle.snp.makeConstraints { make in
            make.leading.equalTo(productView).offset(10)
            make.trailing.equalTo(productView).offset(-10)
            make.top.equalTo(productImage.snp.bottom).offset(10)
            make.bottom.equalTo(productView).offset(-10)
        }

        productImage.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(productView)
            make.height.equalTo(productImage.snp.width).multipliedBy(25.0/21.0)
        }
        
        productImage.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(productView)
            make.height.equalTo(productImage.snp.width).multipliedBy(25.0/21.0)
        }
    }
    
    func setShadowColor() {
        // Set corner radius for rounded corners
        productView.backgroundColor = .white
        productView.layer.cornerRadius = 15
        // Add shadow to the view
        productView.layer.shadowColor = UIColor.black.cgColor
        productView.layer.shadowOpacity = 0.2
        productView.layer.shadowOffset = CGSize(width: 4, height: 4)
        productView.layer.shadowRadius = 4
        // Disable view's boundary restrictions for shadow to appear
        productView.layer.masksToBounds = false
        // Set corner radius for the image view
        productImage.layer.cornerRadius = 15
        // Mask the specified corners of the image view with rounded corners
        productImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // Clip the image to make the rounded corners effective
        productImage.clipsToBounds = true
    }
    
}
