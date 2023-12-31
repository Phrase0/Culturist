//
//  AnimationTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import Gemini

class AnimationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var animationCollectionView: GeminiCollectionView!
    
    var timer: Timer?
    // Used to keep track of the currently displayed banner
    var imageIndex = 0
    var randomSixItems: [ArtDatum] = []
    var allData: [ArtDatum] = [] {
        didSet {
            randomSixItems = getRandomSixItems()
            animationCollectionView.reloadData()
        }
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        animationCollectionView.dataSource = self
        animationCollectionView.delegate = self
        animationCollectionView.isPagingEnabled = true
        
        DispatchQueue.main.async {
            self.setupGeminiAnimation()
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
    }
    
    deinit {
        // Stop the timer when the view is deallocated
        timer?.invalidate()
        timer = nil
    }
    
    func setupGeminiAnimation() {
        animationCollectionView.gemini
            .scaleAnimation()
            .scale(0.8)
            .scaleEffect(.scaleUp)
            .ease(.easeOutCirc)
    }
    
    func getRandomSixItems() -> [ArtDatum] {
        let shuffledData = self.allData.shuffled()
        if shuffledData.isEmpty {
            return []
        }
        let remainingItems = Array(shuffledData.prefix(6))
        // get the firest item
        let firstItem = remainingItems[0]
        // return 7 items
        return remainingItems + [firstItem]
    }
    
    // Banner auto-scroll animation
    @objc func changeBanner() {
        guard !randomSixItems.isEmpty else {
            // If randomSixItems is empty, do not perform the animation
            return
        }
        
        var indexPath: IndexPath
        imageIndex += 1
        if imageIndex < randomSixItems.count {
            // If the displayed image index is less than the total count, show the next one
            indexPath = IndexPath(item: imageIndex, section: 0)
            // Add automatic scrolling animation
            animationCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        } else {
            // If the current image index is equal to the total count and there is no next image, select the first one
            imageIndex = 0
            indexPath = IndexPath(item: 0, section: 0)
            animationCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        
        // Set the next call's time interval based on the current image index
        let timeInterval: TimeInterval = (imageIndex == randomSixItems.count - 1) ? 1.0 : 5.0
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
    }
}

extension AnimationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return randomSixItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = animationCollectionView.dequeueReusableCell(withReuseIdentifier: "AnimationCollectionViewCell", for: indexPath) as? AnimationCollectionViewCell else { return UICollectionViewCell() }
        let viewArray = [UIColor.Color1, UIColor.Color2, UIColor.Color3, UIColor.Color4, UIColor.Color5, UIColor.Color6, UIColor.Color1]
        let itemData = randomSixItems[indexPath.item]
        cell.animationView.backgroundColor = viewArray[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.animationImage.kf.setImage(with: url)
        cell.productTitle.text = itemData.title
        self.animationCollectionView.animateCell(cell)
        
        return cell
    }
    
    func parentViewController() -> HomeViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? HomeViewController {
                return viewController
            }
        }
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let homeViewController = parentViewController() {
            guard let detailVC = homeViewController.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
            detailVC.detailDesctription = randomSixItems[indexPath.item]
            homeViewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animationCollectionView.animateVisibleCells()
        // hand gesture
        if scrollView == animationCollectionView {
            // currentpage index
            let xOffset = scrollView.contentOffset.x
            let pageWidth = scrollView.frame.width
            let currentPage = Int((xOffset + pageWidth / 2) / pageWidth)
            imageIndex = currentPage
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.animationCollectionView.animateCell(cell)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AnimationTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set item size to match the collection view's bounds
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
