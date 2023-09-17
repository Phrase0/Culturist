//
//  HomeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/13.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
  
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let firebaseManager = FirebaseManager()
    
    var result: [ArtDatum] = []
    var mySearchController: UISearchController?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        settingSearchController()
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (mySearchController?.isActive)! {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (mySearchController?.isActive)! {
            return result.count
        } else {
            if section == 0 {
                print(artProducts1.count)
                return artProducts1.count
            } else if section == 1 {
                print(artProducts6.count)
                return artProducts6.count
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }

        if (mySearchController?.isActive)! {
            let itemData = result[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
            
        } else {
            
            if indexPath.section == 0 {
                let itemData = artProducts1[indexPath.item]
                let url = URL(string: itemData.imageURL)
                cell.productImage.kf.setImage(with: url)
                cell.productTitle.text = itemData.title
            } else if indexPath.section == 1 {
                let itemData = artProducts6[indexPath.item]
                let url = URL(string: itemData.imageURL)
                cell.productImage.kf.setImage(with: url)
                cell.productTitle.text = itemData.title
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
        
        if let selectedIndexPaths = self.homeCollectionView.indexPathsForSelectedItems,
           let selectedIndexPath = selectedIndexPaths.first {
            if indexPath.section == 0 {
                detailVC.detailDesctription = artProducts1[selectedIndexPath.row]
                firebaseManager.addData(exhibitionUid: artProducts1[selectedIndexPath.row].uid)
                
            } else if indexPath.section == 1 {
                detailVC.detailDesctription = artProducts6[selectedIndexPath.row]
                firebaseManager.addData(exhibitionUid: artProducts6[selectedIndexPath.row].uid)
            }
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)
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
                self.homeCollectionView.reloadData()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func settingSearchController() {
        mySearchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = mySearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        mySearchController?.searchResultsUpdater = self
        mySearchController?.searchBar.placeholder = "搜尋展覽"
        //        mySearchController?.searchBar.barTintColor = .blue
        //        mySearchController?.searchBar.tintColor = .red
        mySearchController?.searchBar.searchBarStyle = .prominent
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            homeCollectionView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        let filtered1 = artProducts1.filter { artData in
            let title = artData.title.lowercased()
            let locationName = artData.showInfo.first?.locationName.lowercased() ?? ""
            let location = artData.showInfo.first?.location.lowercased() ?? ""

            return title.contains(searchText.lowercased()) || locationName.contains(searchText.lowercased()) || location.contains(searchText.lowercased())
        }

        let filtered6 = artProducts6.filter { artData in
            let title = artData.title.lowercased()
            let locationName = artData.showInfo.first?.locationName.lowercased() ?? ""
            let location = artData.showInfo.first?.location.lowercased() ?? ""

            return title.contains(searchText.lowercased()) || locationName.contains(searchText.lowercased()) || location.contains(searchText.lowercased())
        }

        result = filtered1 + filtered6
    }

}
