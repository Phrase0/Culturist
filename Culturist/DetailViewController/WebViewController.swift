//
//  WebViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/6.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: urlString!)!
                let request = URLRequest(url: url)
                webView.load(request)
        let backImage = UIImage.asset(.Icons_36px_Back)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // reset navigationBarAppearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
