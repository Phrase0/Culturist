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
            
            // ---------------------------------------------------

            cell.likeButtonHandler = { [weak self] sender in
                sender.isSelected = !sender.isSelected
                if self?.isLiked == true {
                    // 如果已经喜欢了，执行移除喜欢的操作
                    self?.removeFavorite()
                } else {
                    // 如果还没有喜欢，执行添加喜欢的操作
                    self?.addFavorite()
                }
            }
            
            // ---------------------------------------------------
        }
        return cell
    }

    func addFavorite() {
        // 创建 LikeData 对象并设置相应的 exhibitionUid、coffeeShopUid 或 bookShopUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        // 调用添加喜欢数据的函数
        firebaseManager.addLikeData(likeData: likeData)
        // 更新标志以表示用户已经喜欢了该项目
        isLiked = true
    }

    // 移除喜欢的操作
    func removeFavorite() {
        // 创建 LikeData 对象并设置相应的 exhibitionUid、coffeeShopUid 或 bookShopUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        
        // 调用移除喜欢数据的函数
        firebaseManager.removeLikeData(likeData: likeData)
        
        // 更新标志以表示用户取消了喜欢该项目
        isLiked = false
    }
}
