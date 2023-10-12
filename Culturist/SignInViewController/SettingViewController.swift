//
//  SettingViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/2.
//

import UIKit

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
        let alertController = UIAlertController(title: "登出",
                                                message: "您確定要登出嗎？",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.goBackToRootVC()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "刪除帳號",
                                                message: "您確定要刪除帳號嗎？",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.firebaseManager.removeUserData()
            self.goBackToRootVC()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goBackToRootVC() {
        // clean user data
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
