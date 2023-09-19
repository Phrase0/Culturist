//
//  BookShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Kingfisher
import CoreLocation
import MapKit

class BookShopViewController: UIViewController {

    @IBOutlet weak var bookShopTableView: UITableView!
    var bookShop: BookShop?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookShopTableView.delegate = self
        bookShopTableView.dataSource = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
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
            cell.mapNavigationButtonHandler = { [weak self] sender in
                let targetCoordinate = CLLocationCoordinate2D(latitude: Double(bookShop.latitude)!, longitude: Double(bookShop.longitude)!)
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
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "POIViewController") as? POIViewController else { return }
                detailVC.routes = response.routes
                detailVC.name = bookShop?.name
                detailVC.latitude = Double(bookShop!.latitude)
                detailVC.longitude = Double(bookShop!.longitude)
                //self.navigationController?.pushViewController(detailVC, animated: true)
                self.present(detailVC, animated: true)
            }
        })
    }
    
    // ---------------------------------------------------
}

// MARK: - CLLocationManagerDelegate

@available(iOS 11.0, *)
extension BookShopViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}
