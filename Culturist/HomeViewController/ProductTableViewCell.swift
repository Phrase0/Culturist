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
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let firebaseManager = FirebaseManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        productCollectionView.register(ProductHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    }
    
}

extension ProductTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            print(artProducts1.count)
            return artProducts1.count
        } else {
            print(artProducts6.count)
            return artProducts6.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.section == 0 {
            let itemData = artProducts1[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        } else if indexPath.section == 1 {
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

            if indexPath.section == 0 {
                detailVC.detailDesctription = artProducts1[indexPath.item]
            } else if indexPath.section == 1 {
                detailVC.detailDesctription = artProducts6[indexPath.item]
            }

            homeViewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }


}


// MARK: - UICollectionViewDelegateFlowLayout
extension ProductTableViewCell: UICollectionViewDelegateFlowLayout {
    // Header content
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as? ProductHeaderView {
            if indexPath.section == 0 {
                headerView.titleLabel.text = "音樂"
            } else if indexPath.section == 1 {
                headerView.titleLabel.text = "展覽"
            }
            // You can set different titles for different sections
            return headerView
        }
        return UICollectionReusableView()
    }
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 25, columnCount: 2)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = productCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((productCollectionView.bounds.width - 32 - interitemSpace * (columnCount-1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 230/173)
        // Header height
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 100)
        
        // Set content insets
        productCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        return flowLayout.itemSize
    }
}

// MARK: - ProductManagerDelegate
extension ProductTableViewCell: ArtManagerDelegate {
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
                self.productCollectionView.reloadData()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}
