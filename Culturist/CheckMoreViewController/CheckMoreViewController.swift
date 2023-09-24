//
//  CheckMoreViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/24.
//

import UIKit

class CheckMoreViewController: UIViewController {

    @IBOutlet weak var checkMoreCollectionView: UICollectionView!
    
    var artProducts1 = [ArtDatum]()
    var artProducts6 = [ArtDatum]()
    var artManager1 = ArtProductManager()
    var artManager6 = ArtProductManager()
    let firebaseManager = FirebaseManager()
    
    // searchResult
    var searchResult: [ArtDatum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMoreCollectionView.delegate = self
        checkMoreCollectionView.dataSource = self
        artManager1.delegate = self
        artManager6.delegate = self
        artManager1.getArtProductList(number: "1")
        artManager6.getArtProductList(number: "6")
        setupCustomNavigationBarButton()
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.title = "音樂"
    }
    
    // MARK: - custom navigationItem button
    private func setupCustomNavigationBarButton() {
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        customButton.tintColor = .B2
        customButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        customButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)

        let customBarButtonItem = UIBarButtonItem(customView: customButton)
        navigationItem.leftBarButtonItem = customBarButtonItem
    }

    @objc private func customButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CheckMoreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return artProducts1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = checkMoreCollectionView.dequeueReusableCell(withReuseIdentifier: "CheckMoreCollectionViewCell", for: indexPath) as? CheckMoreCollectionViewCell else { return UICollectionViewCell() }
            let itemData = artProducts1[indexPath.item]
            let url = URL(string: itemData.imageURL)
            cell.productImage.kf.setImage(with: url)
            cell.productTitle.text = itemData.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController  else { return }
                detailVC.detailDesctription = searchResult[indexPath.item]
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
        checkMoreCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 12.0)
        return flowLayout.itemSize
    }

}

// MARK: - ProductManagerDelegate
extension CheckMoreViewController: ArtManagerDelegate {
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
                self.checkMoreCollectionView.reloadData()
            }
        }
    }
    
    func manager(_ manager: ArtProductManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}
