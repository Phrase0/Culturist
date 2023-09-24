//
//  CheckMoreViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/24.
//

import UIKit

class CheckMoreViewController: UIViewController {

    @IBOutlet weak var checkMoreCollectionView: UICollectionView!

    let firebaseManager = FirebaseManager()
    
    // result
    var result: [ArtDatum] = []
    var navigationItemTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMoreCollectionView.delegate = self
        checkMoreCollectionView.dataSource = self
        
        navigationItem.title = "\(navigationItemTitle!)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .B2
    }

    @objc private func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CheckMoreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = checkMoreCollectionView.dequeueReusableCell(withReuseIdentifier: "CheckMoreCollectionViewCell", for: indexPath) as? CheckMoreCollectionViewCell else { return UICollectionViewCell() }
            let itemData = result[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
                detailVC.detailDesctription = result[indexPath.item]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CheckMoreViewController: UICollectionViewDelegateFlowLayout {
    
    // Number of items per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the floor function to round down the decimal places, as having decimal places might cause the total width to exceed the screen width
        return configureCellSize(interitemSpace: 10, lineSpace: 20, columnCount: 2)
    }
    
    // Configure cell size and header size
    func configureCellSize(interitemSpace: CGFloat, lineSpace: CGFloat, columnCount: CGFloat) -> CGSize {
        
        guard let flowLayout = checkMoreCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        let width = floor((checkMoreCollectionView.bounds.width - 32 - interitemSpace * (columnCount - 1)) / columnCount)
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = interitemSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: width, height: width * 11/7)
        
        // Set content insets
        checkMoreCollectionView.contentInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 12.0)
        return flowLayout.itemSize
    }

}

