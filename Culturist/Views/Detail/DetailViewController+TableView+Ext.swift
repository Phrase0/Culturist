//
//  DetailViewController-TableView-Ext.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/19.
//

import UIKit
import Kingfisher
import EventKitUI
import MapKit
import SafariServices

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
        if let detailDesctription {
            configureCell(cell, with: detailDesctription)
            // MARK: - coffeeBtnTapped
            cell.searchCoffeeButtonHandler = { [weak self] _ in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "CoffeeShopMapViewController") as? CoffeeShopMapViewController  else { return }
                // Default semaphore value is 0 (initial value is 0)
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.global().async {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString("\(detailDesctription.showInfo[0].location)") { (placemarks, error) in
                        if let error {
                            print("Geocoding error: \(error.localizedDescription)")
                            // Signal the semaphore to continue execution in case of an error
                            semaphore.signal()
                            return
                        }
                        if let placemarks = placemarks, let placemark = placemarks.first {
                            detailVC.exhibitionLocation = detailDesctription.showInfo[0].locationName
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
            
            // MARK: - BookButtonTapped
            cell.searchBookButtonHandler = { [weak self] _ in
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "BookShopMapViewController") as? BookShopMapViewController  else { return }
                // Default semaphore value is 0 (initial value is 0)
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.global().async {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString("\(detailDesctription.showInfo[0].location)") { (placemarks, error) in
                        if let error {
                            print("Geocoding error: \(error.localizedDescription)")
                            // Signal the semaphore to continue execution in case of an error
                            semaphore.signal()
                            return
                        }
                        if let placemarks = placemarks, let placemark = placemarks.first {
                            detailVC.exhibitionLocation = detailDesctription.showInfo[0].locationName
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
            
            // MARK: - likeBtnTapped
            if isLiked == false {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            
            cell.likeButtonHandler = { [weak self] _ in
                if KeychainItem.currentUserIdentifier.isEmpty {
                    // If there is no user identifier in Keychain, navigate to SignInViewController
                    guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController  else { return }
                    let navVC = UINavigationController(rootViewController: detailVC)
                    navVC.modalPresentationStyle = .fullScreen
                    navVC.modalTransitionStyle = .crossDissolve
                    self?.present(navVC, animated: true)
                } else {
                    if self?.isLiked == true {
                        // if isLiked, removeFavorite
                        self?.removeFavorite()
                        cell.likeBtn.isSelected = false
                    } else {
                        self?.addFavorite()
                        cell.likeBtn.isSelected = true
                    }
                }
            }
            
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
        }
        return cell
    }
    
    func configureCell(_ cell: DetailTableViewCell, with detailDescription: ArtDatum) {
        let url = URL(string: detailDescription.imageURL)
        cell.detailImageView.kf.setImage(with: url)
        cell.titleLabel.text = detailDescription.title
        
        // set time
        if let startTime = formatTime(detailDescription.showInfo.first?.time) {
            cell.startTimeLabel.text = startTime
        }
        if let endTime = formatTime(detailDescription.showInfo.last?.endTime) {
            cell.endTimeLabel.text = endTime
        }
        
        cell.locationLabel.text = detailDescription.showInfo[0].locationName
        cell.addressLabel.text = detailDescription.showInfo[0].location
        
        if !detailDescription.showInfo[0].price.isEmpty {
            cell.priceLabel.text = "$:\(detailDescription.showInfo[0].price)"
        } else {
            cell.priceLabel.text = ""
        }
        cell.descriptionLabel.text = detailDescription.descriptionFilterHTML
    }
    
    func formatTime(_ timeString: String?) -> String? {
        guard let timeString = timeString else {
            return nil
        }
        let components = timeString.split(separator: ":")
        if components.count >= 2 {
            return "\(components[0]):\(components[1])"
        } else {
            return timeString
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        // cauculate 1/2 creen height
        let oneTwiceScreenHeight = view.frame.height / 2
        if contentOffsetY >= oneTwiceScreenHeight {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundColor = UIColor(white: 0, alpha: 0.1)
            navigationBarAppearance.shadowColor = .clear
            self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            
        } else {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.shadowColor = .clear
            self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        }
    }    
}

// MARK: - DetailTableViewCellDelegate
extension DetailViewController: DetailTableViewCellDelegate {
    func webBtnTapped(sender: UIButton) {
        let safariVC = SFSafariViewController(url: NSURL(string: detailDesctription!.sourceWebPromote)! as URL)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func addEventBtnTapped(sender: UIButton) {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (granted, error) in
                if error != nil {
                    print("Error requesting access to events: \(error?.localizedDescription ?? "Unknown error")")
                } else if granted {
                    DispatchQueue.main.async {
                        self.showEventViewController()
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                self.showEventViewController()
            }
        case .denied, .restricted:
            print("Event access is denied or restricted.")
        @unknown default:
            break
        }
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
        // check if calendar is exist or not
        if let calendar = findAppCalendar() {
            self.appCalendar = calendar
        } else {
            // if check if calendar isn't exist, create one
            self.appCalendar = createAppCalendar()
        }
        let eventVC = EKEventEditViewController()
        // don't forget the delegate
        eventVC.editViewDelegate = self
        eventVC.eventStore = EKEventStore()
        
        let event = EKEvent(eventStore: eventVC.eventStore)
        event.calendar = appCalendar
        event.title = detailDesctription?.title
        if let startTime = changeDateFormatter(dateString: detailDesctription?.showInfo.first?.time), let endTime = changeDateFormatter(dateString: detailDesctription?.showInfo.first?.time) {
            event.startDate = startTime
            event.endDate = endTime
        } else {
            event.startDate = Date()
            event.endDate = Date()
        }
        eventVC.event = event
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        eventVC.navigationBar.standardAppearance = navigationBarAppearance
        present(eventVC, animated: true)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
        if action == .saved {
            // Event is saved, show a success message
            let alert = UIAlertController(title: nil, message: "儲存成功，已加入行事曆", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func changeDateFormatter(dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
}

// MARK: - SFSafariViewControllerDelegate
extension DetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
