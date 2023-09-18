//
//  RecommendViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit

class RecommendViewController: UIViewController {

    @IBOutlet weak var recommendCollectionView: UICollectionView!
    
    var recommendProducts = [ArtDatum]()
    var recommendationList = [RecommendationData]()
    let firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recommendCollectionView.dataSource = self
        recommendCollectionView.delegate = self
        firebaseManager.collectionDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.readRecommendationData()
        print(recommendationList)
    }
    

}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension RecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
     return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = recommendCollectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCollectionViewCell", for: indexPath) as? RecommendCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = "123"

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
            self.recommendationList = recommendationData
        }
    }
    
    func manager(_ manager: FirebaseManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}
