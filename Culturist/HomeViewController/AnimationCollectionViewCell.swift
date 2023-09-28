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
        contentView.backgroundColor = .black
        contentView.addSubview(animationImage)
        
    }
    
    func setupConstraints() {
        animationImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(width).multipliedBy(222.0/390.0)
        }
    }

}
