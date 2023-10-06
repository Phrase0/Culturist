//
//  ProductTableViewCell.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/23.
//

import UIKit
import Kingfisher

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    var productIndexPath: Int?
    let firebaseManager = FirebaseManager()
    
    var artProducts1: [ArtDatum] = [] {
        didSet {
            productCollectionView.reloadData()
        }
    }
    
    var artProducts6: [ArtDatum] = [] {
        didSet {
            productCollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
    }
    
}

extension ProductTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if productIndexPath == 1 {
            return artProducts1.count
        } else {
            return artProducts6.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        if productIndexPath == 1 {
            let itemData = artProducts1[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        } else if productIndexPath == 2 {
            let itemData = artProducts6[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        }
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
            
            if productIndexPath == 1 {
                detailVC.detailDesctription = artProducts1[indexPath.item]
                firebaseManager.addRecommendData(exhibitionUid: artProducts1[indexPath.item].uid, title: artProducts1[indexPath.item].title, category: artProducts1[indexPath.item].category, location: artProducts1[indexPath.item].showInfo[0].location, locationName: artProducts1[indexPath.item].showInfo[0].locationName)
            } else if productIndexPath == 2 {
                detailVC.detailDesctription = artProducts6[indexPath.item]
                firebaseManager.addRecommendData(exhibitionUid: artProducts6[indexPath.row].uid, title: artProducts6[indexPath.item].title, category: artProducts6[indexPath.row].category, location: artProducts6[indexPath.item].showInfo[0].location, locationName: artProducts6[indexPath.item].showInfo[0].locationName)
            }
            
            homeViewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 10, columnCount: 2)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = productCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((productCollectionView.bounds.width - 32 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 11/7)
        
        // Set content insets
        productCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 10.0)
        
        return flowLayout.itemSize
    }
}
