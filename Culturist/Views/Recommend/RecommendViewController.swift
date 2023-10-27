//
//  RecommendViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import UIKit
import Gemini
import NVActivityIndicatorView
import MJRefresh

class RecommendViewController: UIViewController {
    
    @IBOutlet weak var recommendCollectionView: GeminiCollectionView!
    
    // total products
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let recommendationManager = FirebaseManager()
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    // create DispatchGroup
    let group = DispatchGroup()
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR0, padding: 0)
    
    let firebaseManager = FirebaseManager()
    
    // MARK: - recommendProducts
    var filterData = [RecommendationData]()
    // peek view indexpath
    var indexPathItem: Int?
    
    var recommendProducts: [ArtDatum] {
        let allProducts = artProducts1 + artProducts6
        if let firstFilterData = self.filterData.first {
            let searchTitleTerm = firstFilterData.title
            let searchLocationTerm = firstFilterData.location.prefix(6)
            let searchLocationNameTerm = firstFilterData.locationName
            // Use `filter` to search data
            var filteredData = allProducts.filter { data in
                let titleContains = data.title.contains(searchTitleTerm)
                let locationContains = data.showInfo.first?.location.contains(searchLocationTerm)
                let locationNameContains = data.showInfo.first?.locationName.contains(searchLocationNameTerm)
                // Return true if any of the properties contain similar text
                return titleContains || locationContains ?? false || locationNameContains ?? false
            }
            
            // Check the number of filtered data after filtering
            let resultCount = filteredData.count
            // If the result count is less than 10, recommend by hitRate to reach 10
            if resultCount < 10 {
                let remainingCount = 10 - resultCount
                let sortedProducts = allProducts.sorted { $0.hitRate > $1.hitRate }
                let topProducts = Array(sortedProducts.prefix(remainingCount))
                filteredData.append(contentsOf: topProducts)
            }
            
            let topResults = Array(filteredData.prefix(10))
            return topResults
        } else {
            // if filterData have no data, sort by hitRate
            let sortedProducts = allProducts.sorted { $0.hitRate > $1.hitRate }
            let result = Array(sortedProducts.prefix(10))
            return result
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAnimation()
        loading.startAnimating()
        
        recommendCollectionView.dataSource = self
        recommendCollectionView.delegate = self
        
        if HomeViewController.loadAPIFromWeb == true {
            artManager1.delegate = self
            artManager6.delegate = self
            group.enter()
            group.enter()
            // Load data asynchronously
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.artManager1.getArtProductList(number: "1")
                self?.artManager6.getArtProductList(number: "6")
            }
            print("loadAPIFromWeb")
        } else {
            // use firebase to get data
            concertDataManager.concertDelegate = self
            exhibitionDataManager.exhibitionDelegate = self
            concertDataManager.fetchConcertData()
            exhibitionDataManager.fetchExhibitionData()
            print("loadAPIFromFirebase")
        }
        
        // use firebase to get recommend data
        recommendationManager.collectionDelegate = self
        
        recommendCollectionView.gemini
            .scaleAnimation()
            .scale(0.7)
            .scaleEffect(.scaleUp)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.group.notify(queue: .main) {[weak self] in
            guard let self = self else { return }
            if !KeychainItem.currentUserIdentifier.isEmpty {
                self.loading.stopAnimating()
                self.recommendationManager.readFilterRecommendationData()
            } else {
                self.filterData.removeAll()
                DispatchQueue.main.async {
                    self.loading.stopAnimating()
                    self.recommendCollectionView.reloadData()
                }
            }
        }
        // pullToRefresh trailer
        let trailer = MJRefreshNormalTrailer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                if HomeViewController.loadAPIFromWeb == true {
                    group.enter()
                    group.enter()
                    // Load data asynchronously
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        self?.artManager1.getArtProductList(number: "1")
                        self?.artManager6.getArtProductList(number: "6")
                        // Notify on the main queue when both calls are complete
                        self?.group.notify(queue: .main) {
                            DispatchQueue.main.async {
                                self?.loading.stopAnimating()
                                self?.recommendCollectionView.reloadData()
                            }
                        }
                    }
                    print("loadAPIFromWeb")
                } else {
                    // use firebase to get data
                    concertDataManager.fetchConcertData()
                    exhibitionDataManager.fetchExhibitionData()
                    self.group.notify(queue: .main) { [weak self] in
                        DispatchQueue.main.async {
                            self?.loading.stopAnimating()
                            self?.recommendCollectionView.reloadData()
                        }
                    }
                    print("loadAPIFromFirebase")
                }
                self.recommendCollectionView.mj_trailer?.endRefreshing()
            }
        }
        trailer.setTitle("側拉", for: .idle)
        trailer.setTitle("松開刷新", for: .pulling)
        trailer.setTitle("側拉刷新中", for: .refreshing)
        // trailer.stateLabel?.isHidden = true
        trailer.autoChangeTransparency(true).link(to: self.recommendCollectionView)
    }
    
    // MARK: - Function
    
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
        
        cell.productTime.text = "\(itemData.startDate)-\(itemData.endDate)"
        self.recommendCollectionView.animateCell(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.detailDesctription = recommendProducts[indexPath.row]
        if !KeychainItem.currentUserIdentifier.isEmpty {
            firebaseManager.addRecommendData(
                exhibitionUid: recommendProducts[indexPath.item].uid,
                title: recommendProducts[indexPath.item].title,
                category: recommendProducts[indexPath.item].category,
                location: recommendProducts[indexPath.item].showInfo[0].location,
                locationName: recommendProducts[indexPath.item].showInfo[0].locationName)
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
    
    // MARK: - Peek the detail page
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            
            // create detail page peek
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailVC.detailDesctription = self.recommendProducts[indexPath.item]
            // set peek preview position, let information more clear
            detailVC.isPreviewing = true
            self.indexPathItem = indexPath.item
            return detailVC
        }, actionProvider: { _ -> UIMenu? in
            return nil
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.detailDesctription = self.recommendProducts[(self.indexPathItem!)]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension  RecommendViewController: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 10, columnCount: 1)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = recommendCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((recommendCollectionView.bounds.width - 80 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 105/75)
        // Set content insets
        recommendCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 40.0, bottom: 40.0, right: 40.0)
        return flowLayout.itemSize
    }
    
}

extension RecommendViewController: FirebaseCollectionDelegate {
    func manager(_ manager: FirebaseManager, didGet recommendationData: [RecommendationData]) {
        self.filterData = recommendationData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.recommendCollectionView.reloadData()
        }
    }
}

// MARK: - ArtManagerDelegate
extension RecommendViewController: ArtManagerDelegate {
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
        print("can't not get api data")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            // self.group.leave()
        }
    }
    
}

// MARK: - FirebaseDataDelegate
extension RecommendViewController: FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            self.recommendCollectionView.reloadData()
        }
    }
    func manager(_ manager: ConcertDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
}

extension RecommendViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            self.recommendCollectionView.reloadData()
        }
    }
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
        }
    }
}
