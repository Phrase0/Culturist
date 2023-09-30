//
//  BookShopTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit

class BookShopTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    
    // bookshop intro title
    @IBOutlet weak var shopIntro: UILabel!
    
    var mapNavigationButtonHandler: ((UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mapNavigation(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        mapNavigationButtonHandler?(sender)
    }
    
    func setBackgroundColor() {
        backgroundColorView.backgroundColor = .white
        backgroundColorView.layer.cornerRadius = 15
        // Mask the specified corners of the image view with rounded corners
        backgroundColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // Clip the image to make the rounded corners effective
        backgroundColorView.clipsToBounds = true
    }

}
