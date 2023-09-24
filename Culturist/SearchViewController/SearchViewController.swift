//
//  SearchViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/24.
//

import UIKit
import Kingfisher

class SearchViewController: UIViewController {

    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let firebaseManager = FirebaseManager()
    
    // searchResult
    var searchResult: [ArtDatum] = []
    var mySearchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        settingSearchController()
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (mySearchController?.isActive)! {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (mySearchController?.isActive)! {
            return searchResult.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        
        if (mySearchController?.isActive)! {
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
        searchCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 12.0)
        return flowLayout.itemSize
    }

}

// MARK: - ProductManagerDelegate
extension SearchViewController: ArtManagerDelegate {
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
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func settingSearchController() {
        mySearchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = mySearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        mySearchController?.searchResultsUpdater = self
        mySearchController?.searchBar.placeholder = "搜尋展覽"
        mySearchController?.searchBar.searchBarStyle = .prominent
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            searchCollectionView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        var filteredProducts = artProducts1 + artProducts6
        filteredProducts = filteredProducts.filter { artData in
            let title = artData.title.lowercased()
            let locationName = artData.showInfo.first?.locationName.lowercased() ?? ""
            let location = artData.showInfo.first?.location.lowercased() ?? ""
            
            return title.contains(searchText.lowercased()) || locationName.contains(searchText.lowercased()) || location.contains(searchText.lowercased())
        }
        searchResult = filteredProducts
    }
    
}
