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
        
        // set tableView.contentInset fill the screen
        coffeeShopTableView.contentInsetAdjustmentBehavior = .never
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
            
            if !coffeeShop.openTime.isEmpty {
                cell.openTimeLabel.text = "營業時間：\(coffeeShop.openTime)"
            } else {
                cell.openTimeLabel.text = "營業時間：暫無資料"
            }
            cell.wifiLabel.text = "\(coffeeShop.wifi) ★"
            cell.seatLabel.text = "\(coffeeShop.seat) ★"
            cell.quietLabel.text = "\(coffeeShop.quiet) ★"
            cell.tastyLabel.text = "\(coffeeShop.tasty) ★"
            cell.cheapLabel.text = "\(coffeeShop.cheap) ★"
            cell.musicLabel.text = "\(coffeeShop.music) ★"
            
            if !coffeeShop.limitedTime.isEmpty {
                cell.limitTimeLabel.text = coffeeShop.limitedTime
            } else {
                cell.limitTimeLabel.text = "-"
            }
            
            if !coffeeShop.socket.isEmpty {
                cell.socketLabel.text = coffeeShop.socket
            } else {
                cell.socketLabel.text = "-"
            }
            
            let random = Int.random(in: 1...15)
            cell.coffeeImageView.image = UIImage(named: "\(random)")
            cell.mapNavigationButtonHandler = { [weak self] _ in
                let targetCoordinate = CLLocationCoordinate2D(latitude: Double(coffeeShop.latitude)!, longitude: Double(coffeeShop.longitude)!)
                let destinationPlacemark = MKPlacemark(coordinate: targetCoordinate)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                // getDirections method，pass taget MKMapItem
                self?.getDirections(to: destinationMapItem)
            }
        }
        return cell
    }
    
    // ---------------------------------------------------
    func getDirections(to mapLocation: MKMapItem) {
        // Get the user's current location
        guard let userLocation = locationManager.location else {
            // If unable to retrieve the user's location, display an error message
            showAlert(message: NSLocalizedString("無法找到您目前的位置"))
            return
        }
        
        // Coordinates of the target location
        let targetCoordinate = CLLocationCoordinate2D(latitude: Double(coffeeShop!.latitude)!, longitude: Double(coffeeShop!.longitude)!)
        let targetLocation = CLLocation(latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
        
        // Calculate the distance between the current location and the target location
        let distance = userLocation.distance(from: targetLocation)
        
        // Convert the distance to kilometers
        let distanceInKilometers = distance / 1000.0
        
        // If the distance is greater than 5 kilometers, display a warning
        if distanceInKilometers > 3.0 {
            showAlert(message: NSLocalizedString("超出可導航範圍，請重新選取鄰近的咖啡館"))
        } else {
            // refreshControl.startAnimating()
            let request = MKDirections.Request()
            request.source = MKMapItem.forCurrentLocation()
            request.destination = mapLocation
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculate(completionHandler: { response, error in
                //                defer {
                //                    DispatchQueue.main.async { [weak self] in
                //                        self?.refreshControl.stopAnimating()
                //                    }
                //                }
                if let error {
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
                    let navVC = UINavigationController(rootViewController: detailVC)
                    navVC.modalPresentationStyle = .fullScreen
                    self.present(navVC, animated: true)
                }
            })
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("警告"), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("確定"), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate

@available(iOS 11.0, *)
extension CoffeeShopViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
