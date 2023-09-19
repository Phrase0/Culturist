//
//  BookShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Kingfisher

class BookShopViewController: UIViewController {

    @IBOutlet weak var bookShopTableView: UITableView!
    var bookShop: BookShop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookShopTableView.delegate = self
        bookShopTableView.dataSource = self
    }
    
}

extension BookShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookShopTableViewCell", for: indexPath) as? BookShopTableViewCell else {return UITableViewCell()}
        if let bookShop = bookShop {
            cell.titleLabel.text = bookShop.name
            cell.addressLabel.text = bookShop.address
            cell.openTimeLabel.text = bookShop.openTime
            cell.phoneLabel.text = bookShop.phone
            cell.introLabel.text = bookShop.intro
            let url = URL(string: bookShop.representImage)
            cell.bookImageView.kf.setImage(with: url)
        }
        return cell
    }
}
