//
//  ProfileViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit
import Kingfisher
import FSCalendar_Persian
import EventKit
import EventKitUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundWhiteView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    // @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventsTableView: UITableView!
    var eventStore = EKEventStore()
    var events: [EKEvent] = []
    var selectedDate: Date?
    
    let firebaseManager = FirebaseManager()
    let userDefault = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        setCalendarAppearance()
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        setProfileImage()
        setCorner()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(goToSetting))
        navigationItem.rightBarButtonItem?.tintColor = .GR0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAccess()
        // notify if sign in or log out, change the default picture
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignIn), name: Notification.Name("UserDidSignIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignOutOrDelete), name: Notification.Name("UserDidSignOutOrDelete"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func todayBtn(_ sender: UIButton) {
        // Get the current date
        let today = Date()
        // Use the `select` method of FSCalendar to select the current month
        calendar.select(today)
        // Scroll to the current month
        calendar.setCurrentPage(today, animated: true)
        selectedDate = today
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
    }
    
    @IBAction func imageViewTapped(_ sender: UIButton) {
        if KeychainItem.currentUserIdentifier.isEmpty {
            // If there is no user identifier in Keychain, navigate to SignInViewController
            guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController  else { return }
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
            self.present(navVC, animated: true)
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePickerController = UIImagePickerController()
                // check image resource
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - function
    @objc private func goToSetting() {
        // Check if the current user identifier exists in Keychain
        if KeychainItem.currentUserIdentifier.isEmpty {
            // If there is no user identifier in Keychain, navigate to SignInViewController
            guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController  else { return }
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
            self.present(navVC, animated: true)
        } else {
            // If there is a user identifier in Keychain, navigate to TabBarController
            guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController  else { return }
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
            self.present(navVC, animated: true)
        }
    }
    
    @objc func userDidSignIn() {
        firebaseManager.readImage { imageUrl in
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                DispatchQueue.main.async {
                    self.profileImageView.kf.setImage(with: url)
                }
            } else {
                self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                self.profileImageView.tintColor = .GR4
            }
        }
        //        if let imageUrl = UserDefaults.standard.string(forKey: "url"), let url = URL(string: imageUrl) {
        //            DispatchQueue.main.async {
        //                self.profileImageView.kf.setImage(with: url)
        //            }
        //        } else {
        //            self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        //            self.profileImageView.tintColor = .GR4
        //        }
    }
    
    @objc func userDidSignOutOrDelete() {
        self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        self.profileImageView.tintColor = .GR4
    }
    
    func setProfileImage() {
        // ---------------------------------------------------
        if KeychainItem.currentUserIdentifier.isEmpty {
            // If there is no user identifier in Keychain, navigate to SignInViewController
            self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            self.profileImageView.tintColor = .GR4
        } else {
            firebaseManager.readImage { imageUrl in
                if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                    DispatchQueue.main.async {
                        self.profileImageView.kf.setImage(with: url)
                    }
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                    self.profileImageView.tintColor = .GR4
                }
            }
        }
        // ---------------------------------------------------
        //        if KeychainItem.currentUserIdentifier.isEmpty {
        //            // If there is no user identifier in Keychain, navigate to SignInViewController
        //            self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        //            self.profileImageView.tintColor = .GR4
        //        } else {
        //            if let imageUrl = UserDefaults.standard.string(forKey: "url"), let url = URL(string: imageUrl) {
        //                DispatchQueue.main.async {
        //                    self.profileImageView.kf.setImage(with: url)
        //                }
        //            } else {
        //                self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        //                self.profileImageView.tintColor = .GR4
        //            }
        //        }
    }
    
    func setCorner() {
        backgroundWhiteView.backgroundColor = .white
        backgroundWhiteView.layer.cornerRadius = 15
        backgroundWhiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundWhiteView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 55
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.backgroundColor = .white
        profileImageView.clipsToBounds = true
        imageBtn.layer.cornerRadius = 55
        imageBtn.clipsToBounds = true
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // close ImagePickerController
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let imageData = image.jpegData(compressionQuality: 0.0001) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            firebaseManager.storeImage(imageData: imageData)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // close ImagePickerController
        picker.dismiss(animated: true, completion: nil)
    }
}
