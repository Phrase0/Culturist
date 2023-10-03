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
        let productView = UIView()
        return productView
    }()
    
    lazy var productView: UIView = {
        let productView = UIView()
        return productView
    }()
 
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        productTitle.numberOfLines = 1
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 5) {
            productTitle.font = pingFangFont
        } else {
            productTitle.font = UIFont.systemFont(ofSize: 5)
            print("no font type")
        }
        productTitle.textAlignment = .center
        return productTitle
    }()
    
    lazy var productTime: UILabel = {
        let productTitle = UILabel()
        productTitle.numberOfLines = 1
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 5) {
            productTitle.font = pingFangFont
        } else {
            productTitle.font = UIFont.systemFont(ofSize: 5)
            print("no font type")
        }
        productTitle.textAlignment = .center
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
            make.leading.top.trailing.bottom.equalTo(productBackView).inset(5)
            
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
    
    func setShadowColor() {
        productBackView.backgroundColor = .GR3
        //productBackView.backgroundColor = UIColor(red: 142/255, green: 121/255, blue: 84/255, alpha: 1)
        productView.backgroundColor = .white
        productBackView.layer.shadowColor = UIColor.black.cgColor
        productBackView.layer.shadowOpacity = 0.4
        productBackView.layer.shadowOffset = CGSize(width: 4, height: 4)
        productBackView.layer.shadowRadius = 4
        productBackView.layer.masksToBounds = false
        productImage.clipsToBounds = true
    }
    
}
