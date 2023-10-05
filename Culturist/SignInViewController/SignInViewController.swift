//
//  SignInViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/1.
//

import UIKit
import AuthenticationServices

class SignInViewController: UIViewController {
    
    let firebaseManager = FirebaseManager()

    @IBOutlet weak var signInBtn: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCorner()
        performExistingAccountSetupFlows()
    }
    
    @IBAction func didTapSignIn(_ sender: Any) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // - Tag: perform_appleid_password_request
    // Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func setCorner() {
        signInBtn.layer.cornerRadius = 30
        signInBtn.clipsToBounds = true
    }
    
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            let fullName = "\(firstName ?? "") \(lastName ?? "")"
            let email = appleIDCredential.email
            firebaseManager.addUserData(id: userIdentifier, fullName: fullName, email: email)
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserIdentifierInKeychain(userIdentifier)

            // Create an instance of the tab bar controller
            let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CulturistTabBarController") as! UITabBarController

            // set the selected index of the tab bar to determine the initial tab
            tabBarController.selectedIndex = 0 // 0 is the index of the first tab

            // Switch to the main interface using the tab bar controller            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                sceneDelegate.window = window
            }

        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserIdentifierInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "peiyun.Culturist", account: "userIdentifier").saveItem(userIdentifier)
            print("ID:\(KeychainItem.currentUserIdentifier)")
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Show error
        print(error.localizedDescription)
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
