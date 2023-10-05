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
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // total products
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    
    let recommendationManager = FirebaseManager()
    let concertDataManager = ConcertDataManager()
    let exhibitionDataManager = ExhibitionDataManager()
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR0, padding: 0)
    
    // MARK: - recommendProducts
    var filterData = [RecommendationData]()
    var recommendProducts: [ArtDatum] {
        let filteredProducts = artProducts1 + artProducts6
        if let firstFilterData = self.filterData.first {
            let searchTitleTerm = firstFilterData.title
            let searchLocationTerm = firstFilterData.location.prefix(3)
            let searchLocationNameTerm = firstFilterData.locationName
            
            // use `filter` to search data
            let filteredData = filteredProducts.filter { data in
                // Use the range(of:options:) to determine if it contains the specified substring
                let titleContains = data.title.range(of: searchTitleTerm, options: .caseInsensitive) != nil
                let locationContains = data.showInfo.first?.location.range(of: searchLocationTerm, options: .caseInsensitive) != nil
                let locationNameContains = data.showInfo.first?.locationName.range(of: searchLocationNameTerm, options: .caseInsensitive) != nil
                // return true if any of the properties contain similar text
                return titleContains || locationContains || locationNameContains
            }
            let top15Results = Array(filteredData.prefix(2))
            return top15Results
        } else {
            // if filterData have no data
            // sort by hitRate
            let sortedProducts = filteredProducts.sorted { $0.hitRate > $1.hitRate }
            // Get the first 15 items of data, or return an empty array if there is no data
            let result = Array(sortedProducts.prefix(2))
            return result
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .B4
        setAnimation()
        loading.startAnimating()
        
        recommendCollectionView.dataSource = self
        recommendCollectionView.delegate = self
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        // use firebase to get recommend data
        recommendationManager.collectionDelegate = self
        recommendationManager.readFilterRecommendationData()
        // use firebase to get data
        concertDataManager.concertDelegate = self
        exhibitionDataManager.exhibitionDelegate = self
        //        concertDataManager.fetchConcertData()
        //        exhibitionDataManager.fetchExhibitionData()
        recommendCollectionView.gemini
            .scaleAnimation()
            .scale(0.7)
            .scaleEffect(.scaleUp) // or .scaleDown
        
        //        backgroundImageView.image = UIImage(named: "background")
        //        backgroundImageView.contentMode = .scaleAspectFill
        //        backgroundImageView.layer.opacity = 0.6
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(filterData)

        // pullToRefresh trailer
        let trailer = MJRefreshNormalTrailer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                self.artManager1.getArtProductList(number: "1")
                self.artManager6.getArtProductList(number: "6")
                self.recommendCollectionView.mj_trailer?.endRefreshing()
            }
        }
        trailer.setTitle("側拉", for: .idle)
        trailer.setTitle("松開刷新", for: .pulling)
        trailer.setTitle("側拉刷新中", for: .refreshing)
        // trailer.stateLabel?.isHidden = true
        trailer.autoChangeTransparency(true).link(to: self.recommendCollectionView)
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
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
        detailVC.detailDesctription = recommendProducts[indexPath.row]
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
        recommendCollectionView.contentInset = UIEdgeInsets(top: 20.0, left: 40.0, bottom: 40.0, right: 40.0)
        return flowLayout.itemSize
    }
    
}

extension RecommendViewController: FirebaseCollectionDelegate {
    func manager(_ manager: FirebaseManager, didGet recommendationData: [RecommendationData]) {
        self.filterData = recommendationData
        DispatchQueue.main.async {
            self.recommendCollectionView.reloadData()
        }
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
                    DispatchQueue.main.async {
                        self.recommendCollectionView.reloadData()
                        self.loading.stopAnimating()
                    }
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
    func manager(_ manager: ConcertDataManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum]) {
        self.artProducts1 = concertData
        DispatchQueue.main.async {
            self.recommendCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
}

extension RecommendViewController: FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum]) {
        self.artProducts6 = exhibitionData
        DispatchQueue.main.async {
            self.recommendCollectionView.reloadData()
            self.loading.stopAnimating()
        }
    }
}
