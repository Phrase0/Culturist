//
//  AnimationTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit

class AnimationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var animationCollectionView: UICollectionView!
    
    private let pageControl = UIPageControl()
    // Used to keep track of the currently displayed banner
    var imageIndex = 0

    var allData: [ArtDatum] = [] {
        didSet {
            updateRandomSixItems()
        }
    }
// Use the `shuffled()` method to shuffle the order of the array
    var randomSixItems: [ArtDatum] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animationCollectionView.dataSource = self
        animationCollectionView.delegate = self
        animationCollectionView.isPagingEnabled = true
        setupPageControl()
        // Auto scroll animation, set to switch every 2 seconds
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
        
    }
    
    func updateRandomSixItems() {
        let shuffledData = self.allData.shuffled()
        // Get the first six items, and it's okay if the array length is less than six
        self.randomSixItems = Array(shuffledData.prefix(6))
        // Reload the collection view to display the new data
        animationCollectionView.reloadData()
    }

    // Banner auto-scroll animation
    @objc func changeBanner() {
        var indexPath: IndexPath
        imageIndex += 1
        if imageIndex < randomSixItems.count {
            // If the displayed cell is less than the total count, display the next one
            indexPath = IndexPath(item: imageIndex, section: 0)
            // Actions to perform when adding auto-scroll animation
            animationCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        } else {
            // If the displayed cell is equal to the total count and there is no next image, select the first one
            imageIndex = -1
            indexPath = IndexPath(item: 0, section: 0)
            // Actions to perform when adding auto-scroll animation
            animationCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        pageControl.currentPage = imageIndex
    }
    
    // MARK: - PageControl
    func setupPageControl() {
        pageControl.numberOfPages = 6
        pageControl.currentPage = imageIndex
        pageControl.currentPageIndicatorTintColor = UIColor.GR2
        pageControl.pageIndicatorTintColor = UIColor.GR3!.withAlphaComponent(0.8)
        //pageControl.backgroundStyle = .minimal
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(animationCollectionView.snp.bottom).offset(-10)
            make.trailing.equalTo(animationCollectionView.snp.trailing)
        }
    }
}
extension AnimationTableViewCell: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == animationCollectionView {
            // currentpage index
            let xOffset = scrollView.contentOffset.x
            let pageWidth = scrollView.frame.width
            let currentPage = Int((xOffset + pageWidth / 2) / pageWidth)
            // update pageControl
            pageControl.currentPage = currentPage
            imageIndex = currentPage
        }
    }
}

extension AnimationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return randomSixItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = animationCollectionView.dequeueReusableCell(withReuseIdentifier: "AnimationCollectionViewCell", for: indexPath) as? AnimationCollectionViewCell else { return UICollectionViewCell() }
        let itemData = randomSixItems[indexPath.item]
        let url = URL(string: itemData.imageURL)
        cell.animationImage.kf.setImage(with: url)
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}
