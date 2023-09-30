//
//  HomeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    var mySearchController = UISearchController(searchResultsController: nil)
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    var buttonTag: Int?
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR2, padding: 0)
     
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        setAnimation()
        loading.startAnimating()

        // use api to get data
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        
        // use firebase to get data
        concertDataManager.concertDelegate = self
        exhibitionDataManager.exhibitionDelegate = self
        //        concertDataManager.fetchConcertData()
        //        exhibitionDataManager.fetchExhibitionData()
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        searchButton.tintColor = .GR2
        navigationItem.rightBarButtonItem = searchButton

    }
    func setAnimation() {
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    @objc func searchButtonTapped() {
        guard let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        let allProducts = self.artProducts1 + self.artProducts6
        searchVC.allProducts = allProducts
        navigationController?.pushViewController(searchVC, animated: true)

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
            cell.allData = self.artProducts1 + self.artProducts6
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
            cell.productIndexPath = 1
            cell.artProducts1 = self.artProducts1
            cell.artProducts6 = self.artProducts6
            return cell
        } else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
            cell.productIndexPath = 2
            cell.artProducts1 = self.artProducts1
            cell.artProducts6 = self.artProducts6
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            buttonTag = 1
            return headerView(title: "音樂")
        } else if section == 2 {
            buttonTag = 2
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
        button.setTitleColor(UIColor.GR1, for: .normal)
        button.setTitle("查看更多", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.tag = buttonTag ?? 0
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
        guard let checkMoreVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckMoreViewController") as? CheckMoreViewController else { return }
        let section = sender.tag
        if section == 1 {
            checkMoreVC.result = artProducts1
            checkMoreVC.navigationItemTitle = "音樂"
        } else {
            checkMoreVC.result = artProducts6
            checkMoreVC.navigationItemTitle = "展覽"
        }

        navigationController?.pushViewController(checkMoreVC, animated: true)
    }
    
}


// MARK: - ProductManagerDelegate
extension HomeViewController: ArtManagerDelegate {
    func manager(_ manager: ArtProductManager, didGet artProductList: [ArtDatum]) {
        DispatchQueue.main.async {
            if artProductList.isEmpty {
                print("no api data")
            } else {
                if manager === self.artManager1 {
                    self.artProducts1 = artProductList
                } else if manager === self.artManager6 {
                    self.artProducts6 = artProductList
                }
            }
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
                self.loading.stopAnimating()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        // print(error.localizedDescription)
        self.loading.stopAnimating()
    }
    
}

// MARK: - FirebaseDataDelegate
extension HomeViewController: FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async {
            self.homeTableView.reloadData()
            self.loading.stopAnimating()
        }
    }

}

extension HomeViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async {
            self.homeTableView.reloadData()
            self.loading.stopAnimating()
        }
    }
}
