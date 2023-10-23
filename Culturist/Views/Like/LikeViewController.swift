//
//  LikeViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/18.
//

import UIKit
import NVActivityIndicatorView
import MJRefresh
import SnapKit

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
        return filteredLikes
    }
    
    lazy var noDataNoteLabel: UILabel = {
        let noDataNoteLabel = UILabel()
        noDataNoteLabel.numberOfLines = 1
        noDataNoteLabel.textColor = .B2
        noDataNoteLabel.text = "開始添加展覽到您的收藏清單吧"
        if let pingFangFont = UIFont(name: "PingFangTC-Regular", size: 17) {
            noDataNoteLabel.font = pingFangFont
        } else {
            noDataNoteLabel.font = UIFont.systemFont(ofSize: 17)
            print("no font type")
        }
        return noDataNoteLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noDataNoteLabel)
        
        setAnimation()
        setupConstraints()
        loading.startAnimating()
        
        firebaseManager.likeDelegate = self
        likeCollectionView.dataSource = self
        likeCollectionView.delegate = self
        
        if HomeViewController.loadAPIFromWeb == true {
            artManager1.delegate = self
            artManager6.delegate = self
            group.enter()
            group.enter()
            // Load data asynchronously
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.artManager1.getArtProductList(number: "1")
                self?.artManager6.getArtProductList(number: "6")
                // Notify on the main queue when both calls are complete
                self?.group.notify(queue: .main) {
                    self?.dataLoaded()
                }
            }
            print("loadAPIFromWeb")
        } else {
            // use firebase to get data
            concertDataManager.concertDelegate = self
            exhibitionDataManager.exhibitionDelegate = self
            concertDataManager.fetchConcertData()
            exhibitionDataManager.fetchExhibitionData()
            self.group.notify(queue: .main) { [weak self] in
                self?.dataLoaded()
            }
            print("loadAPIFromFirebase")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataNoteLabel.isHidden = true
        
        if !KeychainItem.currentUserIdentifier.isEmpty {
            firebaseManager.fetchUserLikeData { _ in
                if self.likeData.isEmpty == true {
                    self.noDataNoteLabel.isHidden = false
                } else {
                    self.noDataNoteLabel.isHidden = true
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.likeCollectionView.reloadData()
                }
            }
        } else {
            self.noDataNoteLabel.isHidden = false
            self.likeData.removeAll()
            self.likeCollectionView.reloadData()
        }
    }

    // MARK: - Function
    // load api data
    func dataLoaded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            self.likeCollectionView.reloadData()
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
    
    func setupConstraints() {
        noDataNoteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
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
        detailVC.detailDesctription = likeEXProducts[indexPath.row]
        if !KeychainItem.currentUserIdentifier.isEmpty {
            firebaseManager.addRecommendData(
                exhibitionUid: likeEXProducts[indexPath.item].uid,
                title: likeEXProducts[indexPath.item].title,
                category: likeEXProducts[indexPath.item].category,
                location: likeEXProducts[indexPath.item].showInfo[0].location,
                locationName: likeEXProducts[indexPath.item].showInfo[0].locationName)
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
        print(error.localizedDescription)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            // self.group.leave()
        }
    }
    
}

// MARK: - FirebaseDataDelegate
extension LikeViewController: FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
    
}

extension LikeViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.likeCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
}
