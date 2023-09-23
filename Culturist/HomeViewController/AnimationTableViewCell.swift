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
        
    }

}

extension AnimationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = animationCollectionView.dequeueReusableCell(withReuseIdentifier: "AnimationCollectionViewCell", for: indexPath) as? AnimationCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
    
}
