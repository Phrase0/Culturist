//
//  HomeCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit

import SnapKit

class ProductCollectionViewCell: UICollectionViewCell {
    lazy var productTitle: UILabel = {
        let productTitle = UILabel()
        return productTitle
    }()
    
    lazy var productImage: UIImageView = {
        let productImage = UIImageView()
        return productImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(productTitle)
        addSubview(productImage)
        productImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}
