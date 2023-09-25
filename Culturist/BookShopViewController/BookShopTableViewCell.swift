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
    
    // bookshop intro title
    @IBOutlet weak var shopIntro: UILabel!
    
    var mapNavigationButtonHandler: ((UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mapNavigation(_ sender: UIButton) {
        mapNavigationButtonHandler?(sender)
    }

}
