//
//  SignInViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/1.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class SignInViewController: UIViewController {

    let firebaseManager = FirebaseManager()

    // Unhashed nonce.
    fileprivate var currentNonce: String?

    @IBOutlet weak var signInBtn: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCorner()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .GR0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // performExistingAccountSetupFlows()
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapSignIn(_ sender: Any) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
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

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            // Initialize a Firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error authenticating with Firebase: \(error.localizedDescription)")
                    return
                }

                // Successfully signed in with Firebase
                guard let user = authResult?.user else { return }
                let userIdentifier = user.uid
                let firstName = appleIDCredential.fullName?.givenName
                let lastName = appleIDCredential.fullName?.familyName
                let fullName = "\(firstName ?? "") \(lastName ?? "")"
                let email = appleIDCredential.email ?? user.email

                // Save user data to Firestore
                self.firebaseManager.addUserData(id: userIdentifier, fullName: fullName, email: email)

                // Store the userIdentifier in the keychain
                self.saveUserIdentifierInKeychain(userIdentifier)

                if !KeychainItem.currentUserIdentifier.isEmpty {
                    NotificationCenter.default.post(name: Notification.Name("UserDidSignIn"), object: nil)
                    self.dismiss(animated: true)
                }
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
