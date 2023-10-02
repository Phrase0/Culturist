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
        navigationItem.leftBarButtonItem?.tintColor = .GR3
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        goBackToRootVC()
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        firebaseManager.removeUserData()
        goBackToRootVC()
    }
    
    func goBackToRootVC() {
        // clean user data
        KeychainItem.deleteUserIdentifierFromKeychain()
        print("KeychainItem:\(KeychainItem.currentUserIdentifier)")
        // checkout to SignInViewController
        if let signInViewController = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = signInViewController
                window.makeKeyAndVisible()
                sceneDelegate.window = window
            }
        }
    }

    func setCorner() {
        logOutBtn.layer.cornerRadius = 30
        logOutBtn.clipsToBounds = true
        deleteBtn.layer.cornerRadius = 30
        deleteBtn.clipsToBounds = true
    }
    
}
