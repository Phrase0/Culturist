//
//  DetailTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit

protocol DetailTableViewCellDelegate: AnyObject {
    func notificationBtnTapped(sender: UIButton)
    func webBtnTapped(sender: UIButton)
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
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var webBtn: UIButton!
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var searchCoffeeButtonHandler: ((UIButton) -> Void)?
    var searchBookButtonHandler: ((UIButton) -> Void)?
    var likeButtonHandler: ((UIButton) -> Void)?
    weak var cellDelegate: DetailTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeBtn.setImage(UIImage.asset(.Icons_24px_BookMark_Normal), for: .normal)
        likeBtn.setImage(UIImage.asset(.Icons_24px_BookMark_Selected_Color), for: .selected)
        setCorner()
    }

    @IBAction func searchCoffeeShop(_ sender: UIButton) {
        searchCoffeeButtonHandler?(sender)
    }
    
    @IBAction func searchBookShop(_ sender: UIButton) {
        searchBookButtonHandler?(sender)
    }
        
    @IBAction func webBtutton(_ sender: UIButton) {
        cellDelegate?.webBtnTapped(sender: sender)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        likeButtonHandler?(sender)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
    }

    @IBAction func notificationBtnTapped(_ sender: UIButton) {
        cellDelegate?.notificationBtnTapped(sender: sender)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func setCorner() {
        detailImageView.translatesAutoresizingMaskIntoConstraints = false
        detailImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.6).isActive = true
        detailImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        detailImageView.layer.cornerRadius = 100
        detailImageView.clipsToBounds = true
        detailImageView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
    }
}
