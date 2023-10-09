//
//  SearchViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/24.
//

import UIKit
import Kingfisher
import SnapKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    let firebaseManager = FirebaseManager()
    
    var allProducts: [ArtDatum] = []
    // searchResult
    var searchResult: [ArtDatum] = []
    var mySearchController = UISearchController(searchResultsController: nil)
    
    lazy var noDataNoteLabel: UILabel = {
        let noDataNoteLabel = UILabel()
        noDataNoteLabel.numberOfLines = 1
        noDataNoteLabel.textColor = .B2
        noDataNoteLabel.text = "找尋您感興趣的音樂會跟展覽"
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 17) {
            noDataNoteLabel.font = pingFangFont
        } else {
            noDataNoteLabel.font = UIFont.systemFont(ofSize: 17)
            print("no font type")
        }
        return noDataNoteLabel
    }()
    
    lazy var noResultNoteLabel: UILabel = {
        let noResultNoteLabel = UILabel()
        noResultNoteLabel.numberOfLines = 1
        noResultNoteLabel.textColor = .B2
        noResultNoteLabel.text = "抱歉，未找到符合條件的搜尋結果"
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 17) {
            noResultNoteLabel.font = pingFangFont
        } else {
            noResultNoteLabel.font = UIFont.systemFont(ofSize: 17)
            print("no font type")
        }
        return noResultNoteLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noDataNoteLabel)
        view.addSubview(noResultNoteLabel)
        noResultNoteLabel.isHidden = true
        setupConstraints()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        settingSearchController()
        navigationItem.title = "搜尋"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .GR0
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupConstraints() {
        noDataNoteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        noResultNoteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if mySearchController.isActive {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if mySearchController.isActive {
            return searchResult.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        
        if mySearchController.isActive {
            let itemData = searchResult[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
        detailVC.detailDesctription = searchResult[indexPath.item]
        firebaseManager.addRecommendData(exhibitionUid: searchResult[indexPath.item].uid, title: searchResult[indexPath.item].title, category: searchResult[indexPath.item].category, location: searchResult[indexPath.item].showInfo[0].location, locationName: searchResult[indexPath.item].showInfo[0].locationName)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 20, columnCount: 2)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = searchCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((searchCollectionView.bounds.width - 32 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 11/7)
        
        // Set content insets
        searchCollectionView.contentInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 12.0)
        return flowLayout.itemSize
    }
    
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func settingSearchController() {
        mySearchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = mySearchController
        mySearchController.hidesNavigationBarDuringPresentation = false
        mySearchController.searchResultsUpdater = self
        let searchBar = mySearchController.searchBar
        searchBar.placeholder = "音樂會或展覽"
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = self
        // Configure the appearance of the search bar
        // Color for the search bar's cursor and icons
        searchBar.tintColor = .GR2
        // Adjust the position of the search text
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
        
        // Configure the appearance of the cancel button
        // Color for the cancel button
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .GR2
        // Customize the title of the cancel button
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            if searchResult.isEmpty && !searchText.isEmpty {
                noResultNoteLabel.isHidden = false
            } else {
                noResultNoteLabel.isHidden = true
            }
            searchCollectionView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        // copy allProducts to searchResult
        searchResult = allProducts
        searchResult = searchResult.filter { artData in
            let title = artData.title.lowercased()
            let locationName = artData.showInfo.first?.locationName.lowercased() ?? ""
            let location = artData.showInfo.first?.location.lowercased() ?? ""
            
            return title.contains(searchText.lowercased()) || locationName.contains(searchText.lowercased()) || location.contains(searchText.lowercased())
        }
        
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        noDataNoteLabel.isHidden = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        noDataNoteLabel.isHidden = false
        noDataNoteLabel.text = "請搜尋音樂會或展覽"
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
