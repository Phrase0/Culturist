//
//  SettingViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/2.
//

import UIKit
import SwiftEntryKit
class SettingViewController: UIViewController {

    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var attributes: EKAttributes = .centerFloat
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCorner()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .GR3
        
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        let colors: [EKColor] = [
          EKColor(red: 69, green: 84, blue: 81),
          EKColor(red: 94, green: 129, blue: 74),
          EKColor(red: 140, green: 165, blue: 134)
        ]

        attributes.entryBackground = .gradient(gradient: .init(colors: colors, startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        

        attributes.roundCorners = .all(radius: 12)
        attributes.displayDuration = .infinity
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
 
        showAlertView(attributes: attributes)
    }
    
    func logOut() {
        // clean user data
        KeychainItem.deleteUserIdentifierFromKeychain()
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
        print("success")
    }
    
    
    func setCorner() {
        logOutBtn.layer.cornerRadius = 30
        logOutBtn.clipsToBounds = true
        deleteBtn.layer.cornerRadius = 30
        deleteBtn.clipsToBounds = true
    }
    
    
    
    private func showAlertView(attributes: EKAttributes) {
        
 
        
        let title = EKProperty.LabelContent(
            text: "登出",
            style: .init(
                font: MainFont.medium.with(size: 15),
                color: .white,
                alignment: .center,
                displayMode: .inferred
            )
        )
        let text = "你確定要登出嗎？"
        let description = EKProperty.LabelContent(
            text: text,
            style: .init(
                font: MainFont.light.with(size: 13),
                color: .white,
                alignment: .center,
                displayMode: .inferred
            )
        )

        let simpleMessage = EKSimpleMessage(
            title: title,
            description: description
        )
        let buttonFont = MainFont.medium.with(size: 16)
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(.GR3!),
            displayMode: .inferred
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "取消",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(.GR3!),
            displayMode: .inferred) {
                SwiftEntryKit.dismiss()
        }

        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(.GR3!),
            displayMode: .inferred
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "確定",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(.GR3!),
            displayMode: .inferred) {
                DispatchQueue.main.async {
                    self.logOut()
                }
                
        }
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton, closeButton,
            separatorColor: EKColor(.GR3!),
            displayMode: .inferred,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            buttonBarContent: buttonsBarContent
        )
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

}
