//
//  DetailTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit

protocol DetailTableViewCellDelegate: AnyObject {
    func notificationBtnTapped(sender: UIButton)
}

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var searchCoffeeButtonHandler: ((UIButton) -> Void)?
    var searchBookButtonHandler: ((UIButton) -> Void)?
    var likeButtonHandler: ((UIButton) -> Void)?
    weak var cellDelegate: DetailTableViewCellDelegate?
    
    @IBOutlet weak var likeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeBtn.setImage(UIImage.asset(.Icons_24px_BookMark_Normal), for: .normal)
        likeBtn.setImage(UIImage.asset(.Icons_24px_BookMark_Selected_Color), for: .selected)

    }

    @IBAction func searchCoffeeShop(_ sender: UIButton) {
        searchCoffeeButtonHandler?(sender)
    }
    
    @IBAction func searchBookShop(_ sender: UIButton) {
        searchBookButtonHandler?(sender)
    }
        
    @IBAction func likeButton(_ sender: UIButton) {
        likeButtonHandler?(sender)
    }
    
    
    @IBAction func notificationBtnTapped(_ sender: UIButton) {
        cellDelegate?.notificationBtnTapped(sender: sender)
    }
    
}
