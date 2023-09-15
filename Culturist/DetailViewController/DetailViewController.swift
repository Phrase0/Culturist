//
//  DetailViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    var detailDesctription: ArtDatum?
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
    }
    
    
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {return UITableViewCell()}
        if let detailDesctription = detailDesctription {
            let url = URL(string: detailDesctription.imageURL)
            cell.detailImageView.kf.setImage(with: url)
            cell.titleLabel.text = detailDesctription.title
            cell.locationLabel.text = detailDesctription.showInfo[0].locationName
            cell.priceLabel.text = detailDesctription.showInfo[0].price
            cell.addressLabel.text = detailDesctription.showInfo[0].location
            cell.startTimeLabel.text = detailDesctription.showInfo[0].time
            cell.endTimeLabel.text = detailDesctription.showInfo[0].endTime
            cell.descriptionLabel.text = detailDesctription.descriptionFilterHTML
            //CoffeeButtonTapped
            cell.searchCoffeeButtonHandler = { [weak self] sender in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "CoffeeShopMapViewController") as? CoffeeShopMapViewController  else { return }
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
            //BookButtonTapped
            cell.searchBookButtonHandler = { [weak self] sender in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "BookShopMapViewController") as? BookShopMapViewController  else { return }
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        }
        return cell
    }
}
