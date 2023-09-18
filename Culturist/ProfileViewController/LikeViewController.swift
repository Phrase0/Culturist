//
//  LikeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit

class LikeViewController: UIViewController {
    
    let firebaseManager = FirebaseManager()
    var likeData = [LikeData]()
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    //products in likeCollection
    var likeEXProducts = [ArtDatum]()
    
    @IBOutlet weak var likeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.likeDelegate = self
        likeCollectionView.dataSource = self
        likeCollectionView.delegate = self
        
        artManager1.delegate = self
        artManager6.delegate = self
        
        
        
        DispatchQueue.global().async { [self] in
            artManager1.getArtProductList(number: "1")

            artManager6.getArtProductList(number: "6")
            self.semaphore.wait()
            // load data
            self.firebaseManager.fetchUserLikeData {_,_ in
                self.semaphore.signal()
            }
            semaphore.wait()
            var filteredProducts = artProducts1 + artProducts6
            // compactMap: a map without nil
            likeEXProducts = likeData.compactMap { like in
                if let exhibitionUid = like.exhibitionUid {
                    return filteredProducts.first { product in
                        return product.uid == exhibitionUid
                    }
                }
                return nil
            }
            print(likeEXProducts)
            print(likeEXProducts.count)
            DispatchQueue.main.async {
                self.likeCollectionView.reloadData()
            }
        }
    }
}

extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likeEXProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikeCollectionViewCell", for: indexPath) as? LikeCollectionViewCell else {return UICollectionViewCell()}
        let itemData = likeEXProducts[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.imageView.kf.setImage(with: url)
        cell.titleLabel.text = itemData.title
        return cell
    }
}

// MARK: - FirebaseLikeDelegate
extension LikeViewController: FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData]) {
        self.likeData = likeData
    }
}

// MARK: - ArtManagerDelegate
extension LikeViewController: ArtManagerDelegate {
    // Call the signal() method of the semaphore in manager(_:didGet:) to notify that the data loading is complete
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
                // Release the semaphore after data loading is completed
                self.semaphore.signal()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}
