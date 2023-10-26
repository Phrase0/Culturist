//
//  DetailViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/15.
//

import UIKit
import EventKitUI

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
    private let group = DispatchGroup()
    let firebaseManager = FirebaseManager()
    // set peek preview position
    var isPreviewing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        isLiked = false
        firebaseManager.likeDelegate = self
        setBackButton()
        // set tableView.contentInset fill the screen
        detailTableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set peek preview position
        if isPreviewing {
            let screenHeight = UIScreen.height
            let yOffset = screenHeight / 4
            let desiredContentOffset = CGPoint(x: 0, y: yOffset)
            detailTableView.setContentOffset(desiredContentOffset, animated: false)
            isPreviewing = false
        }
        // set scroll back
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if !KeychainItem.currentUserIdentifier.isEmpty {
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
        } else {
            self.likeData.removeAll()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // reset navigationBarAppearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }

    // MARK: - functions
    func setBackButton() {
        let backImage = UIImage.asset(.Icons_36px_Back_Black)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }

    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
