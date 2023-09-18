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

protocol FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData])
}
class FirebaseManager {
    
    var collectionDelegate:FirebaseCollectionDelegate?
    var likeDelegate: FirebaseLikeDelegate?
    
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
    // 在页面加载时获取用户的喜欢数据
    func fetchUserLikeData(completion: @escaping ([LikeData]?, Error?) -> Void) {
        let userRef = db.collection("users").document(user.id)
        let likeCollection = userRef.collection("likeCollection")
        
        likeCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching LikeData: \(error)")
                completion(nil, error) // 调用闭包通知发生错误
            } else {
                var userLikes: [LikeData] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let exhibitionUid = data["exhibitionUid"] as? String
                    let coffeeShopUid = data["coffeeShopUid"] as? String
                    let bookShopUid = data["bookShopUid"] as? String
                    
                    let likeData = LikeData(exhibitionUid: exhibitionUid, coffeeShopUid: coffeeShopUid, bookShopUid: bookShopUid)
                    userLikes.append(likeData)
                }
                
                // 将用户的喜欢数据保存在适当的位置，以便在页面上使用
                // 例如，你可以将它们存储在一个成员变量中
                self.likeDelegate?.manager(self, didGet: userLikes)
                print("userLike:\(userLikes)")
                
                // 调用闭包通知操作成功
                completion(userLikes, nil)
                
                // 更新页面以反映用户的喜欢数据
                // 这里可以调用页面的刷新函数或更新 UI 的逻辑
            }
        }
    }


}
