//
//  AnimationTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit

class AnimationTableViewCell: UITableViewCell {

    @IBOutlet weak var animationCollectionView: UICollectionView!
    let images = ["coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo","coffeeDemo"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animationCollectionView.dataSource = self
        animationCollectionView.delegate = self
        animationCollectionView.isPagingEnabled = true
        // Auto scroll animation, set to switch every 2 seconds
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
        
    }
    // Used to keep track of the currently displayed banner
    var imageIndex = 0
    // Banner auto-scroll animation
    @objc func changeBanner() {
        var indexPath: IndexPath
        imageIndex += 1
        if imageIndex < images.count {
            // If the displayed cell is less than the total count, display the next one
            indexPath = IndexPath(item: imageIndex, section: 0)
            // Actions to perform when adding auto-scroll animation
            animationCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        } else {
            // If the displayed cell is equal to the total count and there is no next image, select the first one and immediately call itself
            imageIndex = 0
            indexPath = IndexPath(item: imageIndex, section: 0)
            // Actions to perform when adding auto-scroll animation
            animationCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            changeBanner()
        }
    }

}

extension AnimationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = animationCollectionView.dequeueReusableCell(withReuseIdentifier: "AnimationCollectionViewCell", for: indexPath) as? AnimationCollectionViewCell else { return UICollectionViewCell() }
        cell.animationImage.image = UIImage(named: images[indexPath.row])
        
        cell.animationImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(animationCollectionView.bounds.width)
            make.height.equalTo(animationCollectionView.bounds.width).multipliedBy(222.0/390.0)
            }
        
        return cell
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
