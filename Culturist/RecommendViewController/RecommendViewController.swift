//
//  RecommendViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit

class RecommendViewController: UIViewController {
    
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    
    // total products
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    // 6 recommendProducts
    var recommendProducts = [ArtDatum]()
    // filter data from firebase (choose one)
    var recommendationData = [RecommendationData]()
    let firebaseManager = FirebaseManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recommendCollectionView.dataSource = self
        recommendCollectionView.delegate = self
        firebaseManager.collectionDelegate = self
        
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.readFilterRecommendationData()
        print(recommendationData)
        //filterContentUsingRecommendationData()
        filterContent(for: recommendationData.first?.title ?? "0")
        
    }
    // ---------------------------------------------------
    
    func filterContentUsingRecommendationData() {
        // check if recommendationData isEmpty
        if recommendationData.isEmpty {
            // if recommendationData isEmpty, recommend data for random
            let randomArtProducts1 = getRandomItems(from: artProducts1, count: 3)
            let randomArtProducts6 = getRandomItems(from: artProducts6, count: 3)
            recommendProducts = randomArtProducts1 + randomArtProducts6
        } else {
            // 如果 recommendationData 不为空，使用 recommendationData 的数据来筛选
            recommendProducts = artProducts1 + artProducts6
            recommendProducts = recommendProducts.filter { artData in
                let title = artData.title.lowercased()
                let locationName = artData.showInfo.first?.locationName.lowercased() ?? ""
                let location = artData.showInfo.first?.location.lowercased() ?? ""
                
                return recommendationData.contains { recommendation in
                    let recTitle = recommendation.title.lowercased()
                    let recLocationName = recommendation.locationName.lowercased()
                    let recLocation = recommendation.location.lowercased()
                    
                    return title.contains(recTitle) || locationName.contains(recLocationName) || location.contains(recLocation)
                }
            }
        }
    }


    // 随机从数组中选择指定数量的项
    func getRandomItems<T>(from array: [T], count: Int) -> [T] {
        if array.count <= count {
            return array
        }
        var shuffledArray = array.shuffled()
        return Array(shuffledArray.prefix(count))
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

        recommendProducts = filtered1 + filtered6
    }


    // ---------------------------------------------------
    
    
    
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension RecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(recommendProducts.count)
        return recommendProducts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = recommendCollectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCollectionViewCell", for: indexPath) as? RecommendCollectionViewCell else { return UICollectionViewCell() }
        let itemData = recommendProducts[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.imageView.kf.setImage(with: url)
        cell.titleLabel.text = itemData.title
        cell.descripLabel.text = itemData.descriptionFilterHTML
        
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
}

extension RecommendViewController: FirebaseCollectionDelegate {
    func manager(_ manager: FirebaseManager, didGet recommendationData: [RecommendationData]) {
        DispatchQueue.main.async {
            self.recommendationData = recommendationData
        }
    }
    
    func manager(_ manager: FirebaseManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}

extension RecommendViewController: ArtManagerDelegate {
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
                self.recommendCollectionView.reloadData()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}
