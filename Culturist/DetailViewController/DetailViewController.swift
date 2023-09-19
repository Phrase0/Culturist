//
//  DetailViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit
import Kingfisher
import MapKit

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
            
            // CoffeeButtonTapped
            cell.searchCoffeeButtonHandler = { [weak self] sender in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "CoffeeShopMapViewController") as? CoffeeShopMapViewController  else { return }
                // Default semaphore value is 0 (initial value is 0)
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.global().async {
                    // if data has latitude and longitude
                    if detailDesctription.showInfo[0].latitude != nil && detailDesctription.showInfo[0].longitude != nil {
                        detailVC.latitude = Double(detailDesctription.showInfo[0].latitude!)
                        detailVC.longitude = Double(detailDesctription.showInfo[0].longitude!)
                        // No need to wait, proceed to navigation directly
                        DispatchQueue.main.async {
                            self?.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    } else {
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString("\(detailDesctription.showInfo[0].location)") { (placemarks, error) in
                            if let error = error {
                                print("Geocoding error: \(error.localizedDescription)")
                                // Signal the semaphore to continue execution in case of an error
                                semaphore.signal()
                                return
                            }
                            if let placemarks = placemarks, let placemark = placemarks.first {
                                detailVC.latitude = placemark.location?.coordinate.latitude
                                detailVC.longitude = placemark.location?.coordinate.longitude
                                print("Geocoding successful: Latitude \(placemark.location?.coordinate.latitude ?? 0.0), Longitude \(placemark.location?.coordinate.longitude ?? 0.0)")
                                // Signal the semaphore to notify completion of geocoding
                                semaphore.signal()
                            }
                        }
                    }
                    // Wait for the semaphore to ensure geocoding is completed before navigation
                    semaphore.wait()
                    
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            }

            // BookButtonTapped
            cell.searchBookButtonHandler = { [weak self] sender in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "BookShopMapViewController") as? BookShopMapViewController  else { return }
                // Default semaphore value is 0 (initial value is 0)
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.global().async {
                    // if data has latitude and longitude
                    if detailDesctription.showInfo[0].latitude != nil && detailDesctription.showInfo[0].longitude != nil {
                        detailVC.latitude = Double(detailDesctription.showInfo[0].latitude!)
                        detailVC.longitude = Double(detailDesctription.showInfo[0].longitude!)
                        // No need to wait, proceed to navigation directly
                        DispatchQueue.main.async {
                            self?.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    } else {
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString("\(detailDesctription.showInfo[0].location)") { (placemarks, error) in
                            if let error = error {
                                print("Geocoding error: \(error.localizedDescription)")
                                // Signal the semaphore to continue execution in case of an error
                                semaphore.signal()
                                return
                            }
                            if let placemarks = placemarks, let placemark = placemarks.first {
                                detailVC.latitude = placemark.location?.coordinate.latitude
                                detailVC.longitude = placemark.location?.coordinate.longitude
                                print("Geocoding successful: Latitude \(placemark.location?.coordinate.latitude ?? 0.0), Longitude \(placemark.location?.coordinate.longitude ?? 0.0)")
                                // Signal the semaphore to notify completion of geocoding
                                semaphore.signal()
                            }
                        }
                    }
                    // Wait for the semaphore to ensure geocoding is completed before navigation
                    semaphore.wait()
                    
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            }
        }
        return cell
    }

}
