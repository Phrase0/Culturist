//
//  ProfileViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToLikecollection(_ sender: UIButton) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "LikeViewController") as? LikeViewController  else { return }
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
    }
    
    @IBAction func goToCalendarVC(_ sender: UIButton) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController  else { return }

        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
