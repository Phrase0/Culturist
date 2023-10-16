//
//  HomeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import MJRefresh

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!

    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    var buttonTag: Int?
    // control buttonEnable
    var isButtonEnabled = false
    var searchButton: UIBarButtonItem?
    // create DispatchGroup
    let group = DispatchGroup()
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR0, padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        setAnimation()
        loading.startAnimating()
        
        // use api to get data
        artManager1.delegate = self
        artManager6.delegate = self
        group.enter()
        artManager1.getArtProductList(number: "1")
        group.enter()
        artManager6.getArtProductList(number: "6")

        // MARK: - FireBaseData
        // use firebase to get data
//        concertDataManager.concertDelegate = self
//        exhibitionDataManager.exhibitionDelegate = self
//        concertDataManager.fetchConcertData()
//        exhibitionDataManager.fetchExhibitionData()
        
        // MARK: - navigationTitle
        // Create an empty UIBarButtonItem as the left item
        let leftSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftSpacer.width = 44 // Adjust the width to add left space
        // Add the left item to the navigation bar
        navigationItem.leftBarButtonItems = [leftSpacer]
        
        // Create an image view as the title view
        let imageView = UIImageView(image: UIImage(named: "culturist_logo_green_navTitle"))
        imageView.contentMode = .scaleAspectFit
        // Set the image view as the title view
        navigationItem.titleView = imageView
        
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        searchButton?.tintColor = .GR0
        searchButton?.isEnabled = false
        navigationItem.rightBarButtonItem = searchButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // pullToRefresh Header
        MJRefreshNormalHeader {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                self.group.enter()
                self.artManager1.getArtProductList(number: "1")
                self.group.enter()
                self.artManager6.getArtProductList(number: "6")
                // ---------------------------------------------------
                //                self.concertDataManager.fetchConcertData()
                //                self.exhibitionDataManager.fetchExhibitionData()
                // ---------------------------------------------------
                self.homeTableView.mj_header?.endRefreshing()
            }
        }.autoChangeTransparency(true).link(to: self.homeTableView)
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
                self.loading.stopAnimating()
                self.isButtonEnabled = true
                self.searchButton?.isEnabled = true
            }
        }
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
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        if let pingFangFont = UIFont(name: "PingFangTC-Medium", size: 20) {
            label.font = pingFangFont
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 20)
            print("no font type")
        }
        label.textColor = UIColor.black
        headerView.addSubview(label)
        
        // add button
        let headButton = UIButton()
        headButton.setTitleColor(UIColor.GR0, for: .normal)
        headButton.setTitle("查看更多 >", for: .normal)
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 15) {
            headButton.titleLabel?.font = pingFangFont
        } else {
            headButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            print("no font type")
        }
        headButton.tag = buttonTag ?? 0
        headButton.isEnabled = isButtonEnabled
        headButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        headerView.addSubview(headButton)
        
        // Apply Auto Layout constraints using SnapKit
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview().offset(16)
        }
        
        headButton.snp.makeConstraints { make in
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if artProductList.isEmpty {
                print("no api data")
            } else {
                if manager === self.artManager1 {
                    self.artProducts1 = artProductList
                } else if manager === self.artManager6 {
                    self.artProducts6 = artProductList
                }
            }
            self.group.leave()
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        // print(error.localizedDescription)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            // self.group.leave()
        }
    }
    
}

// MARK: - FirebaseDataDelegate
extension HomeViewController: FirebaseConcertDelegate {
    
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            self.homeTableView.reloadData()
        }
    }
    func manager(_ manager: ConcertDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
}

extension HomeViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            self.homeTableView.reloadData()
        }
    }
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
}
