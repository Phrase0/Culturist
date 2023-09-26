//
//  AnimationCollectionViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit

class AnimationCollectionViewCell: UICollectionViewCell {
    
    lazy var animationImage: UIImageView = {
        let animationImage = UIImageView()
        animationImage.contentMode = .scaleAspectFill
        return animationImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(animationImage)
        }
    }
