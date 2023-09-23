//
//  HomeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var homeTableView: UITableView!
    
    let images = ["coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimationTableViewCell") as? AnimationTableViewCell else { return UITableViewCell() }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
            return cell
        }
    }
}

