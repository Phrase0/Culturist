//
//  AnimationCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit

class AnimationCollectionViewCell: UICollectionViewCell {
    
    let width = UIScreen.main.bounds.width
    
    lazy var animationImage: UIImageView = {
        let animationImage = UIImageView()
        animationImage.contentMode = .scaleAspectFill
        return animationImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(animationImage)
        animationImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(width).multipliedBy(222.0/390.0)
        }
        }
    }
