//
//  ProductCollectionViewCell.swift
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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setShadowColor()
    }
    
    func setShadowColor() {
        // Set corner radius for rounded corners
        productView.layer.cornerRadius = 10
        // Add shadow to the view
        productView.layer.shadowColor = UIColor.black.cgColor
        productView.layer.shadowOpacity = 0.2
        productView.layer.shadowOffset = CGSize(width: 2, height: 2)
        productView.layer.shadowRadius = 4
        // Disable view's boundary restrictions for shadow to appear
        productView.layer.masksToBounds = false
        // Set corner radius for the image view
        productImage.layer.cornerRadius = 10
        // Mask the specified corners of the image view with rounded corners
        productImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // Clip the image to make the rounded corners effective
        productImage.clipsToBounds = true
    }

}
