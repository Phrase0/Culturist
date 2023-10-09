//
//  DetailViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit
import Kingfisher
import MapKit
import EventKitUI
import SafariServices

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    // detailData from home page
    var detailDesctription: ArtDatum?
    
    // like data
    var isLiked: Bool?
    var likeData = [LikeData]()
    
    // appCalendar
    let eventStore = EKEventStore()
    var appCalendar: EKCalendar?
    // set Time
    let dateFormatter = DateFormatter()
    
    // create DispatchGroup
    let group = DispatchGroup()
    let firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        firebaseManager.likeDelegate = self
        isLiked = false

        group.enter()
        firebaseManager.fetchUserLikeData { _ in
             // leave DispatchGroup
            self.group.leave()
        }
        
        // use DispatchGroup notify
        group.notify(queue: .main) {
            let isLiked = self.likeData.contains { like in
                return like.exhibitionUid == self.detailDesctription?.uid
            }
            
            DispatchQueue.main.async {
                self.isLiked = isLiked
                self.detailTableView.reloadData()
            }
        }
        
        // ---------------------------------------------------
        // check if calendar is exist or not
        if let calendar = findAppCalendar() {
            appCalendar = calendar
        } else {
            // if check if calendar isn't exist, create one
            appCalendar = createAppCalendar()
        }
        // ---------------------------------------------------        
        let backImage = UIImage.asset(.Icons_36px_Back_Black)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))

        // set tableView.contentInset fill the screen
        detailTableView.contentInsetAdjustmentBehavior = .never
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .regular)
        navigationBarAppearance.backgroundColor = UIColor(white: 1, alpha: 0.1)
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // reset navigationBarAppearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeDateFormatter(dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
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
            cell.endTimeLabel.text = detailDesctription.showInfo.last?.endTime
            cell.descriptionLabel.text = detailDesctription.descriptionFilterHTML
            // MARK: - coffeeBtnTapped
            cell.searchCoffeeButtonHandler = { [weak self] _ in
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
                            let navVC = UINavigationController(rootViewController: detailVC)
                            navVC.modalPresentationStyle = .fullScreen
                            navVC.modalTransitionStyle = .crossDissolve
                            self?.present(navVC, animated: true)
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
                        // Wait for the semaphore to ensure geocoding is completed before navigation
                        semaphore.wait()
                        
                        DispatchQueue.main.async {
                            let navVC = UINavigationController(rootViewController: detailVC)
                            navVC.modalPresentationStyle = .fullScreen
                            navVC.modalTransitionStyle = .crossDissolve
                            self?.present(navVC, animated: true)
                        }
                    }

                }
            }
            
            // MARK: - BookButtonTapped
            cell.searchBookButtonHandler = { [weak self] _ in
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
                            let navVC = UINavigationController(rootViewController: detailVC)
                            navVC.modalPresentationStyle = .fullScreen
                            navVC.modalTransitionStyle = .crossDissolve
                            self?.present(navVC, animated: true)
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
                        
                        // Wait for the semaphore to ensure geocoding is completed before navigation
                        semaphore.wait()
                        
                        DispatchQueue.main.async {
                            let navVC = UINavigationController(rootViewController: detailVC)
                            navVC.modalPresentationStyle = .fullScreen
                            navVC.modalTransitionStyle = .crossDissolve
                            self?.present(navVC, animated: true)
                        }
                    }
                }
            }
            
            // MARK: - likeBtnTapped
            if isLiked == false {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            
            cell.likeButtonHandler = { [weak self] _ in
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
            // MARK: - notificationBtn & webBtn Tapped
            cell.cellDelegate = self
            let urlString = detailDesctription.sourceWebPromote
            if let url = URL(string: urlString),
               UIApplication.shared.canOpenURL(url) {
                // url can use
                cell.webBtn.isEnabled = true
            } else {
                cell.webBtn.isEnabled = false
            }
            // ---------------------------------------------------
        }
        return cell
    }
    
}

// MARK: - likeCollection function
extension DetailViewController {
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

// MARK: - FirebaseLikeDelegate
extension DetailViewController: FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData]) {
        self.likeData = likeData
    }
}

// MARK: - EKEventEditViewDelegate, UINavigationControllerDelegate
extension DetailViewController: EKEventEditViewDelegate, UINavigationControllerDelegate {
    
    // check if calendar is exist or not
    func findAppCalendar() -> EKCalendar? {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == "CulturistCalendar" {
                return calendar
            }
        }
        return nil
    }
    
    // create a new calendar
    func createAppCalendar() -> EKCalendar? {
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "CulturistCalendar"
        newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
        newCalendar.cgColor = UIColor.GR2?.cgColor
        
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            print("無法創建日曆：\(error.localizedDescription)")
            return nil
        }
    }
    
    func showEventViewController() {
        let eventVC = EKEventEditViewController()
        eventVC.editViewDelegate = self // don't forget the delegate
        eventVC.eventStore = EKEventStore()
        
        let event = EKEvent(eventStore: eventVC.eventStore)
        event.calendar = appCalendar
        event.title = detailDesctription?.title
        if let startTime = changeDateFormatter(dateString: detailDesctription?.showInfo.first?.time), let endTime = changeDateFormatter(dateString: detailDesctription?.showInfo.first?.time) {
            // event.startDate = Date()
            event.startDate = startTime
            event.endDate = endTime
        }
        eventVC.event = event
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        eventVC.navigationBar.standardAppearance = navigationBarAppearance
        present(eventVC, animated: true)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - DetailTableViewCellDelegate
extension DetailViewController: DetailTableViewCellDelegate {
    func webBtnTapped(sender: UIButton) {
        let safariVC = SFSafariViewController(url: NSURL(string: detailDesctription!.sourceWebPromote)! as URL, entersReaderIfAvailable: true)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func notificationBtnTapped(sender: UIButton) {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    // do stuff
                    DispatchQueue.main.async {
                        self.showEventViewController()
                        
                    }
                }
            }
        case .authorized:
            // do stuff
            DispatchQueue.main.async {
                self.showEventViewController()
            }
        default:
            break
        }
        
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - SFSafariViewControllerDelegate
extension DetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
