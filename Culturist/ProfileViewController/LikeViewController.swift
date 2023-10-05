//
//  LikeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit
import NVActivityIndicatorView
import MJRefresh

class LikeViewController: UIViewController {
    
    @IBOutlet weak var likeCollectionView: UICollectionView!

    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    let firebaseManager = FirebaseManager()
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    // create DispatchGroup
    let group = DispatchGroup()
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR0, padding: 0)
    
    var likeData = [LikeData]()
    // products in likeCollection
    var likeEXProducts: [ArtDatum] {
        let filteredProducts = self.artProducts1 + self.artProducts6
        // compactMap: a map without nil
        let filteredLikes = self.likeData.compactMap { like in
            if let exhibitionUid = like.exhibitionUid {
                return filteredProducts.first { product in
                    return product.uid == exhibitionUid
                }
            }
            return nil
        }
        print(filteredLikes.count)
        return filteredLikes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimation()
        loading.startAnimating()
        
        firebaseManager.likeDelegate = self
        likeCollectionView.dataSource = self
        likeCollectionView.delegate = self
        
        artManager1.delegate = self
        artManager6.delegate = self
        
        group.enter()
        artManager1.getArtProductList(number: "1")
        group.enter()
        artManager6.getArtProductList(number: "6")
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.likeCollectionView.reloadData()
                self.loading.stopAnimating()
            }
        }
        
        // MARK: - FireBaseData
//        concertDataManager.concertDelegate = self
//        exhibitionDataManager.exhibitionDelegate = self
//        concertDataManager.fetchConcertData()
//        exhibitionDataManager.fetchExhibitionData()
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
                self.likeCollectionView.mj_header?.endRefreshing()
            }
        }.autoChangeTransparency(true).link(to: self.likeCollectionView)
        
        firebaseManager.fetchUserLikeData { _ in
            DispatchQueue.main.async {
                self.likeCollectionView.reloadData()
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
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likeEXProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikeCollectionViewCell", for: indexPath) as? LikeCollectionViewCell else {return UICollectionViewCell()}
        let itemData = likeEXProducts[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.productImage.kf.setImage(with: url)
        cell.productTitle.text = itemData.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
        
        if let selectedIndexPaths = self.likeCollectionView.indexPathsForSelectedItems,
           let selectedIndexPath = selectedIndexPaths.first {
            detailVC.detailDesctription = likeEXProducts[selectedIndexPath.row]
            firebaseManager.addRecommendData(exhibitionUid: likeEXProducts[indexPath.item].uid, title: likeEXProducts[indexPath.item].title, location: likeEXProducts[indexPath.item].showInfo[0].location, locationName: likeEXProducts[indexPath.item].showInfo[0].locationName)
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LikeViewController: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 20, columnCount: 2)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = likeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((likeCollectionView.bounds.width - 32 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 11/7)
        
        // Set content insets
        likeCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 12.0)
        return flowLayout.itemSize
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
                    self.group.leave()
                }
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.loading.stopAnimating()
            self.group.leave()
        }
    }
    
}

// MARK: - FirebaseDataDelegate
extension LikeViewController: FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async {
            self.likeCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
    
}

extension LikeViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async {
            self.likeCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
}
