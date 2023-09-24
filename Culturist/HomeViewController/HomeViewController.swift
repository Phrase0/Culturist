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

    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        settingSearchController()
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimationTableViewCell") as? AnimationTableViewCell else { return UITableViewCell() }
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
            cell.productIndexPath = 1
            return cell
        } else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
            cell.productIndexPath = 2
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return headerView(title: "音樂")
        } else if section == 2 {
            return headerView(title: "展覽")
        }
        return UIView()
    }
    
    func headerView(title: String) -> UIView {
        // create view
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        // add title
        let label = UILabel()
        label.text = "\(title)"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.black
        headerView.addSubview(label)
        
        // add button
        let button = UIButton()
        button.setTitleColor(UIColor.BL1, for: .normal)
        button.setTitle("查看更多", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        headerView.addSubview(button)
        
        // Apply Auto Layout constraints using SnapKit
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview().offset(16)
        }
        
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.trailing.equalToSuperview().offset(-20)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 30
        }
        
    }

    // MARK: - Button Action
    
    @objc func buttonTapped(_ sender: UIButton) {
        // 處理按鈕點擊事件
        let section = sender.tag
        print("Button tapped in section \(section)")
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
            make.top.equalTo(homeTitleLabel.snp.bottom).offset(6)
            
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return false }
        navigationController?.pushViewController(searchVC, animated: true)  
        // Return false to prevent the search bar from being edited
        return false
    }
}
