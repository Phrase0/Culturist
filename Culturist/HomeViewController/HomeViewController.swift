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
    
    var artProducts = [ArtDatum]()
    var artManager = ArtProductManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        artManager.delegate = self
        artManager.getArtProductList(number: "6")
        
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView:\(artProducts.count)")
        return artProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
        

                let itemData = artProducts[indexPath.item]
                let url = URL(string: itemData.imageURL)
                cell.productImage.kf.setImage(with: url)
                cell.productTitle.text = itemData.title
                return cell
    }
}

//MARK: - ProductManagerDelegate
extension HomeViewController: ArtManagerDelegate {
    func manager(_ manager: ArtProductManager, didGet artProductList: [ArtDatum]) {
            DispatchQueue.main.async {
                self.artProducts = artProductList
                self.homeCollectionView.reloadData()
            }

    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
    
}
