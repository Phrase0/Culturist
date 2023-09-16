//
//  CoffeeShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Kingfisher
import MapKit
import CoreLocation

class CoffeeShopViewController: UIViewController {
    
    @IBOutlet weak var coffeeShopTableView: UITableView!
    var coffeeShop: CoffeeShop?
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coffeeShopTableView.dataSource = self
        coffeeShopTableView.delegate = self
        //locationManager.requestWhenInUseAuthorization()
    }
    
    
}

extension CoffeeShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeShopTableViewCell", for: indexPath) as? CoffeeShopTableViewCell else {return UITableViewCell()}
        if let coffeeShop = coffeeShop {
            cell.titleLabel.text = coffeeShop.name
            cell.addressLabel.text = coffeeShop.address
            cell.openTimeLabel.text = coffeeShop.openTime
            cell.wifiLabel.text = "\(coffeeShop.wifi)"
            cell.seatLabel.text = "\(coffeeShop.seat)"
            cell.quietLabel.text = "\(coffeeShop.quiet)"
            cell.tastyLabel.text = "\(coffeeShop.tasty)"
            cell.cheapLabel.text = "\(coffeeShop.cheap)"
            cell.musicLabel.text = "\(coffeeShop.music)"
            cell.limitTimeLabel.text = coffeeShop.limitedTime
            cell.socketLabel.text = coffeeShop.socket
            cell.standingDeskLabel.text = coffeeShop.standingDesk
            cell.mapNavigationButtonHandler = { [weak self] sender in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "CoffeeMapNavigationViewController") as? CoffeeMapNavigationViewController else { return }
                detailVC.latitude = Double(coffeeShop.latitude)
                detailVC.longitude = Double(coffeeShop.longitude)
                self?.present(detailVC, animated: true)
            }
        }
        return cell
    }
    
}
