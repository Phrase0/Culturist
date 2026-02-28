//
//  SettingViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/2.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    let firebaseManager = FirebaseManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCorner()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .GR0
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("登出"),
                                                message: NSLocalizedString("您確定要登出嗎？"),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("取消"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("確定"), style: .default, handler: { _ in
            NotificationCenter.default.post(name: Notification.Name("UserDidSignOutOrDelete"), object: nil)
            self.goBackToRootVC()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("刪除帳號"),
                                                message: NSLocalizedString("您確定要刪除帳號嗎？"),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("取消"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("確定"), style: .default, handler: { _ in
            // Remove Firestore data first
            self.firebaseManager.removeUserData()

            // Delete Firebase Auth user
            if let user = Auth.auth().currentUser {
                user.delete { error in
                    if let error = error {
                        print("Error deleting Firebase Auth user: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted Firebase Auth user")
                    }
                }
            }

            NotificationCenter.default.post(name: Notification.Name("UserDidSignOutOrDelete"), object: nil)
            self.goBackToRootVC()
        }))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func goBackToRootVC() {
        // Sign out from Firebase Auth
        do {
            try Auth.auth().signOut()
            print("Successfully signed out from Firebase")
        } catch let signOutError as NSError {
            print("Error signing out from Firebase: \(signOutError.localizedDescription)")
        }

        // Clean user data from Keychain
        KeychainItem.deleteUserIdentifierFromKeychain()
        self.dismiss(animated: true)
    }
    
    func setCorner() {
        logOutBtn.layer.cornerRadius = 30
        logOutBtn.clipsToBounds = true
        deleteBtn.layer.cornerRadius = 30
        deleteBtn.clipsToBounds = true
    }
    
}
