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
    
    // detailData from home page
    var detailDesctription: ArtDatum?
    
    let firebaseManager = FirebaseManager()
    var isLiked: Bool?
    var likeData = [LikeData]()
    
    @IBOutlet weak var detailTableView: UITableView!
    let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        firebaseManager.likeDelegate = self
        
        // create DispatchGroup
        let group = DispatchGroup()

        group.enter()
        firebaseManager.fetchUserLikeData {_,_ in 
            group.leave() // 离开 DispatchGroup
        }

        // use DispatchGroup notify
        group.notify(queue: .main) {
            let isLiked = self.likeData.contains { like in
                print(like.exhibitionUid)
                return like.exhibitionUid == self.detailDesctription?.uid
            }
            
            DispatchQueue.main.async {
                self.isLiked = isLiked
                self.detailTableView.reloadData()
            }
        }
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
            
            // ---------------------------------------------------
            if isLiked == false {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            
            cell.likeButtonHandler = { [weak self] sender in
                if self?.isLiked == true {
                    // if isLiked, removeFavorite
                    self?.removeFavorite()
                    cell.likeBtn.isSelected = false
                } else {
                    self?.addFavorite()
                    cell.likeBtn.isSelected = true
                }
            }
            
            // ---------------------------------------------------
        }
        return cell
    }
    
    func addFavorite() {
        // Create a LikeData object and set the corresponding exhibitionUid, coffeeShopUid, or bookShopUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        // Call the function to add liked data
        firebaseManager.addLikeData(likeData: likeData)
        // Update the flag to indicate that the user has liked the item
        isLiked = true
    }
    
    // Remove favorite action
    func removeFavorite() {
        // Create a LikeData object and set the corresponding exhibitionUid, coffeeShopUid, or bookShopUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        // Call the function to remove liked data
        firebaseManager.removeLikeData(likeData: likeData)
        // Update the flag to indicate that the user has unliked the item
        isLiked = false
    }
    
}

extension DetailViewController: FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData]) {
        self.likeData = likeData
    }
}
