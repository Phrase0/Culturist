//
//  ProfileViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit
import Hero

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var backgroundWhiteView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var likeCollectionBtn: UIButton!
    
    @IBOutlet weak var calendarBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = KeychainItem.currentUserName
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .GR3
        profileImageView.backgroundColor = .white
        setCorner()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(goToSetting))
        navigationItem.rightBarButtonItem?.tintColor = .B1
    }

    @IBAction func imageViewTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
          let imagePickerController = UIImagePickerController()
          // check image resource
          imagePickerController.sourceType = .photoLibrary
          imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
          present(imagePickerController, animated: true, completion: nil)
        }
    }
    

    @objc private func goToSetting() {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController  else { return }
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .selectBy(presenting:.fade, dismissing:.fade)
        self.present(navVC, animated: true)
    }

    @IBAction func goToLikecollection(_ sender: UIButton) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "LikeViewController") as? LikeViewController  else { return }
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .selectBy(presenting:.fade, dismissing:.fade)
        self.present(navVC, animated: true)
    }
    
    @IBAction func goToCalendarVC(_ sender: UIButton) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController  else { return }
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .selectBy(presenting:.fade, dismissing:.fade)
        self.present(navVC, animated: true)
    }
    
    func setCorner() {
        backgroundWhiteView.backgroundColor = .white
        backgroundWhiteView.layer.cornerRadius = 15
        backgroundWhiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundWhiteView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 65
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        likeCollectionBtn.layer.cornerRadius = 30
        likeCollectionBtn.clipsToBounds = true
        calendarBtn.layer.cornerRadius = 30
        calendarBtn.clipsToBounds = true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // close ImagePickerController
    picker.dismiss(animated: true, completion: nil)
    if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
    //get user Image
    profileImageView.image = image
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // close ImagePickerController
    picker.dismiss(animated: true, completion: nil)
  }
}
