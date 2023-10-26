//
//  CoffeeShopTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit

class CoffeeShopTableViewCell: UITableViewCell {
     
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var quietLabel: UILabel!
    @IBOutlet weak var tastyLabel: UILabel!
    @IBOutlet weak var cheapLabel: UILabel!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var limitTimeLabel: UILabel!
    @IBOutlet weak var socketLabel: UILabel!
    @IBOutlet weak var coffeeImageView: UIImageView!
        
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var shopView: UIView!
    
    var mapNavigationButtonHandler: ((UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setBackgroundColor()
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
        scoreView.backgroundColor = .B4
        scoreView.layer.cornerRadius = 8
        // Clip the image to make the rounded corners effective
        scoreView.clipsToBounds = true
        shopView.backgroundColor = .B4
        shopView.layer.cornerRadius = 8
        // Clip the image to make the rounded corners effective
        shopView.clipsToBounds = true
    }
}
