//
//  CoffeeShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Kingfisher
import CoreLocation
import MapKit

class CoffeeShopViewController: UIViewController {
    
    @IBOutlet weak var coffeeShopTableView: UITableView!
    var coffeeShop: CoffeeShop?
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coffeeShopTableView.dataSource = self
        coffeeShopTableView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
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
                
                let targetCoordinate = CLLocationCoordinate2D(latitude: Double(coffeeShop.latitude)!, longitude: Double(coffeeShop.longitude)!)
                let destinationPlacemark = MKPlacemark(coordinate: targetCoordinate)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                // getDirections method，pass taget MKMapItem
                self?.getDirections(to: destinationMapItem)
                print("Button Tapped")
//                detailVC.routes = response.routes
//                self?.present(detailVC, animated: true)
            }
        }
        return cell
    }
    
    // ---------------------------------------------------
    func getDirections(to mapLocation: MKMapItem) {
        //refreshControl.startAnimating()

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapLocation
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { response, error in
            defer {
                DispatchQueue.main.async { [weak self] in
                    //self?.refreshControl.stopAnimating()
                }
            }
            if let error = error {
                return print("Error getting directions: \(error.localizedDescription)")
            }
            guard let response = response else {
                return assertionFailure("No error, but no response, either.")
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "NavigationViewController") as? NavigationViewController else { return }
                detailVC.routes = response.routes
                detailVC.name = coffeeShop?.name
                detailVC.latitude = Double(coffeeShop!.latitude)
                detailVC.longitude = Double(coffeeShop!.longitude)
                //self.navigationController?.pushViewController(detailVC, animated: true)
                self.present(detailVC, animated: true)
            }
        })
    }
    
    // ---------------------------------------------------
    
}


// MARK: - CLLocationManagerDelegate

@available(iOS 11.0, *)
extension CoffeeShopViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}
