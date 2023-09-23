//
//  HomeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit
class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var homeTitleLabel: UILabel!
    var mySearchController = UISearchController(searchResultsController: nil)
    let images = ["coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self

        settingSearchController()
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
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



extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func settingSearchController() {
        let searchBar = mySearchController.searchBar
        // navigationItem.searchController = mySearchController
        // navigationItem.hidesSearchBarWhenScrolling = false
        // mySearchController.searchResultsUpdater = self
        searchBar.placeholder = "搜尋展覽"
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        // add Autolayout
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.top.equalTo(homeTitleLabel.snp.bottom).offset(10)
            
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 處理跳轉到下一頁的操作，例如：
        //        let searchVC = ProfileViewController() // 創建下一頁的視圖控制器
        //        navigationController?.pushViewController(searchVC, animated: true) // 執行跳轉
        return false // 返回false以防止搜索欄進行編輯
    }
}
