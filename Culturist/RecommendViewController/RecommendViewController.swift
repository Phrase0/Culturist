//
//  RecommendViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit
import Gemini

class RecommendViewController: UIViewController {
    
    @IBOutlet weak var recommendCollectionView: GeminiCollectionView!
    
    // total products
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    // recommendProducts
    var recommendProducts: [ArtDatum] {
        let filteredProducts = artProducts1 + artProducts6
        // sort by hitRate
        let sortedProducts = filteredProducts.sorted { $0.hitRate > $1.hitRate }
        // Get the first 15 items of data, or return an empty array if there is no data
        let result = Array(sortedProducts.prefix(15))
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recommendCollectionView.dataSource = self
        recommendCollectionView.delegate = self
        //recommendCollectionView.isPagingEnabled = true
        artManager1.delegate = self
        artManager6.delegate = self
        
        // use firebase to get data
        concertDataManager.concertDelegate = self
        exhibitionDataManager.exhibitionDelegate = self
        
        recommendCollectionView.gemini
            .scaleAnimation()
            .scale(0.75)
            .scaleEffect(.scaleUp) // or .scaleDown
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        //        concertDataManager.fetchConcertData()
        //        exhibitionDataManager.fetchExhibitionData()
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension RecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendProducts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = recommendCollectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCollectionViewCell", for: indexPath) as? RecommendCollectionViewCell else { return UICollectionViewCell() }
        let itemData = recommendProducts[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.productImage.kf.setImage(with: url)
        cell.productTitle.text = itemData.title
        self.recommendCollectionView.animateCell(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
        if let selectedIndexPaths = self.recommendCollectionView.indexPathsForSelectedItems,
           let selectedIndexPath = selectedIndexPaths.first {
            detailVC.detailDesctription = recommendProducts[selectedIndexPath.row]
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Animate
        self.recommendCollectionView.animateVisibleCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.recommendCollectionView.animateCell(cell)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension  RecommendViewController: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 15, lineSpace: 20, columnCount: 1)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = recommendCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((recommendCollectionView.bounds.width - 80 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 11/7)
        
        // Set content insets
        recommendCollectionView.contentInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 90.0, right: 40.0)
        return flowLayout.itemSize
    }
    
}

// MARK: - ArtManagerDelegate
extension RecommendViewController: ArtManagerDelegate {
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
                DispatchQueue.main.async {
                    self.recommendCollectionView.reloadData()
                }
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}

// MARK: - FirebaseDataDelegate
extension RecommendViewController: FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async {
            self.recommendCollectionView.reloadData()
        }
    }
    
}

extension RecommendViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async {
            self.recommendCollectionView.reloadData()
        }
    }
}
