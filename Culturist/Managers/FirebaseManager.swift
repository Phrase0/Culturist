//
//  FirebaseManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

protocol FirebaseCollectionDelegate {
    func manager(_ manager: FirebaseManager, didGet recommendationData: [RecommendationData])
    func manager(_ manager: FirebaseManager, didFailWith error: Error)
}

class FirebaseManager {
    
    var collectionDelegate:FirebaseCollectionDelegate?
    
    // Get the Firestore database reference
    let db = Firestore.firestore()
    // Assuming a User object
    let user = User(id: "user_id", name: "user_name", email: "user_email", recommendationData: [], likeData: [])
    
    func addData(exhibitionUid: String, title: String, location: String, locationName: String) {
        // Create a new RecommendationData
        let newRecommendationData = RecommendationData(exhibitionUid: exhibitionUid, title: title, location: location, locationName: locationName)
        // Get the user's document reference
        let userRef = db.collection("users").document(user.id)
        // Create a new collection reference for recommendationData
        let recommendationDataCollection = userRef.collection("recommendationData")
        
        // Create a data dictionary for RecommendationData
        let recommendationData: [String: Any] = [
            "exhibitionUid": newRecommendationData.exhibitionUid,
            "title": newRecommendationData.title,
            "location": newRecommendationData.location,
            "locationName": newRecommendationData.locationName
        ]
        
        // Add RecommendationData to the recommendationData collection
        recommendationDataCollection.addDocument(data: recommendationData) { (error) in
            if let error = error {
                print("Error adding RecommendationData: \(error)")
            } else {
                print("RecommendationData added successfully.")
            }
        }
        
        // Update user document data with id, name, and email
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email
        ]
        
        // Set the user's document data with merge option to update existing data
        userRef.setData(userData, merge: true) { (error) in
            if let error = error {
                print("Error updating user data: \(error)")
            } else {
                print("User data updated successfully.")
            }
        }
    }
    
    
    // ---------------------------------------------------
    func readRecommendationData() {
        let userRef = db.collection("users").document(user.id)
        let recommendationDataCollection = userRef.collection("recommendationData")
        
        // search "recommendationData" documents
        recommendationDataCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching recommendationData: \(error)")
                return
            }
            var recommendationDataList = [RecommendationData]()
            for document in querySnapshot!.documents {
                let data = document.data()
                if let exhibitionUid = data["exhibitionUid"] as? String,
                   let title = data["title"] as? String,
                   let location = data["location"] as? String,
                   let locationName = data["locationName"] as? String {
                    // add RecommendationData to list
                    let recommendationData = RecommendationData(exhibitionUid: exhibitionUid, title: title, location: location, locationName: locationName)
                    recommendationDataList.append(recommendationData)
                }
            }
            self.collectionDelegate?.manager(self, didGet: recommendationDataList)
            
        }
    }
    
    // ---------------------------------------------------
    func readFilterRecommendationData() {
        let userRef = db.collection("users").document(user.id)
        let recommendationDataCollection = userRef.collection("recommendationData")
        
        // search "recommendationData" documents
        recommendationDataCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching recommendationData: \(error)")
                return
            }
            var recommendationDataList = [RecommendationData]()
            
            for document in querySnapshot!.documents {
                let data = document.data()
                
                if let exhibitionUid = data["exhibitionUid"] as? String,
                   let title = data["title"] as? String,
                   let location = data["location"] as? String,
                   let locationName = data["locationName"] as? String {
                    // add RecommendationData to list
                    let recommendationData = RecommendationData(exhibitionUid: exhibitionUid, title: title, location: location, locationName: locationName)
                    recommendationDataList.append(recommendationData)
                }
            }
            
            if !recommendationDataList.isEmpty {
                // calculate every RecommendationData amount
                var counts = [RecommendationData: Int]()
                
                for recommendationData in recommendationDataList {
                    counts[recommendationData, default: 0] += 1
                }
                
                // find  mostRepeatedData
                var mostRepeatedData = recommendationDataList[0]
                var maxCount = counts[mostRepeatedData] ?? 0
                
                for (recommendationData, count) in counts {
                    if count > maxCount {
                        mostRepeatedData = recommendationData
                        maxCount = count
                    }
                }
                
                // recommend mostRepeatedData
                self.collectionDelegate?.manager(self, didGet: [mostRepeatedData])
            } else {
                // if no RecommendationData，recommend for random
                if let randomData = recommendationDataList.randomElement() {
                    self.collectionDelegate?.manager(self, didGet: [randomData])
                } else {
                    // no data could choose
                    self.collectionDelegate?.manager(self, didGet: [])
                }
            }
        }
    }
    
    // ---------------------------------------------------
    func addLikeData(likeData: LikeData) {
        // Get the user's document reference
        let userRef = db.collection("users").document(user.id)
        // Create a new collection reference for likeData
        let likeCollection = userRef.collection("likeCollection")
        
        // Create a data dictionary for LikeData
        var likeDataDict: [String: Any] = [:]
        if let exhibitionUid = likeData.exhibitionUid {
            likeDataDict["exhibitionUid"] = exhibitionUid
        }
        if let coffeeShopUid = likeData.coffeeShopUid {
            likeDataDict["coffeeShopUid"] = coffeeShopUid
        }
        if let bookShopUid = likeData.bookShopUid {
            likeDataDict["bookShopUid"] = bookShopUid
        }
        
        // Add LikeData to the likeCollection
        likeCollection.addDocument(data: likeDataDict) { (error) in
            if let error = error {
                print("Error adding LikeData: \(error)")
            } else {
                print("LikeData added successfully.")
            }
        }
        
        // Update user document data with id, name, and email
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email
        ]
        
        // Set the user's document data with merge option to update existing data
        userRef.setData(userData, merge: true) { (error) in
            if let error = error {
                print("Error updating user data: \(error)")
            } else {
                print("User data updated successfully.")
            }
        }
    }
    
    // ---------------------------------------------------
    // 移除喜欢的数据
    func removeLikeData(likeData: LikeData) {
        // 获取用户文档的引用
        let userRef = db.collection("users").document(user.id)
        
        // 创建一个引用到用户的 likeCollection
        let likeCollection = userRef.collection("likeCollection")
        
        // 创建一个查询，以查找匹配喜欢数据的文档
        var query: Query = likeCollection
        
        if let exhibitionUid = likeData.exhibitionUid {
            query = query.whereField("exhibitionUid", isEqualTo: exhibitionUid)
        }
        
        if let coffeeShopUid = likeData.coffeeShopUid {
            query = query.whereField("coffeeShopUid", isEqualTo: coffeeShopUid)
        }
        
        if let bookShopUid = likeData.bookShopUid {
            query = query.whereField("bookShopUid", isEqualTo: bookShopUid)
        }
        
        // 执行查询，获取匹配的文档并删除它们
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error removing LikeData: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let documentID = document.documentID
                    likeCollection.document(documentID).delete { (error) in
                        if let error = error {
                            print("Error removing LikeData document: \(error)")
                        } else {
                            print("LikeData removed successfully.")
                        }
                    }
                }
            }
        }
        
    }
    // ---------------------------------------------------
}
