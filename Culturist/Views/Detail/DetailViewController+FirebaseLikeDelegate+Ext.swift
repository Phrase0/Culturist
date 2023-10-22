//
//  DetailViewController+FirebaseLikeDelegate+Ext.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/20.
//

import UIKit
// MARK: - FirebaseLikeDelegate
extension DetailViewController: FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData]) {
        self.likeData = likeData
    }
    
    func addFavorite() {
        // Create a LikeData object and set exhibitionUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        // Call the function to add liked data
        firebaseManager.addLikeData(likeData: likeData)
        // Update the flag to indicate that the user has liked the item
        isLiked = true
    }
    
    // Remove favorite action
    func removeFavorite() {
        // Create a LikeData object and set exhibitionUid
        let likeData = LikeData(exhibitionUid: detailDesctription?.uid, coffeeShopUid: nil, bookShopUid: nil)
        // Call the function to remove liked data
        firebaseManager.removeLikeData(likeData: likeData)
        // Update the flag to indicate that the user has unliked the item
        isLiked = false
    }
}
