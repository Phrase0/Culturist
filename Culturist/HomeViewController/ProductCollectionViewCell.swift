//
//  HomeCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit

import SnapKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    //    lazy var productTitle: UILabel = {
//        let productTitle = UILabel()
//        return productTitle
//    }()
//
//    lazy var productImage: UIImageView = {
//        let productImage = UIImageView()
//        return productImage
//    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        addSubview(productTitle)
//        addSubview(productImage)
//        productImage.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
    }

}
