//
//  BookShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Kingfisher
import MapKit

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
            // ---------
            
            cell.mapNavigationButtonHandler = { [weak self] sender in
                
                let currentLocation: MKMapItem = MKMapItem.forCurrentLocation()
                let toCoor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(bookShop.latitude)!, longitude: Double(bookShop.longitude)!)
                let toMKPlacemark: MKPlacemark = MKPlacemark.init(coordinate: toCoor, addressDictionary: nil)
                let toLocation: MKMapItem = MKMapItem.init(placemark: toMKPlacemark)
                toLocation.name = "\(bookShop.name)"

                let options: [String : Any] = [
                    // transpotation
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                    // mapType
                    MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
                    // ShowsTraffic
                    MKLaunchOptionsShowsTrafficKey: true
                ]
                MKMapItem .openMaps(with: [currentLocation,toLocation], launchOptions: options)

            }
            
            // ---------
 
        }
        return cell
    }
}
