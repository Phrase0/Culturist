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
}

protocol FirebaseLikeDelegate {
    func manager(_ manager: FirebaseManager, didGet likeData: [LikeData])
}

protocol FirebaseConcertDelegate {
    func manager(_ manager: FirebaseManager, didGet concertData: [ArtDatum])
}
class FirebaseManager {
    
    var collectionDelegate:FirebaseCollectionDelegate?
    var likeDelegate: FirebaseLikeDelegate?
    var concertDelegate: FirebaseConcertDelegate?
    
    // Get the Firestore database reference
    let db = Firestore.firestore()
    // Assuming a User object
    let user = User(id: "user_id", name: "user_name", email: "user_email", recommendationData: [], likeData: [])
    
    
    // MARK: - Recommendation
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
    // MARK: - LikeCollection
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
    func removeLikeData(likeData: LikeData) {
        let userRef = db.collection("users").document(user.id)
        let likeCollection = userRef.collection("likeCollection")
        
        // Create a query to find documents matching likeCollection data
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
        
        // Execute a query, get matching documents and delete them
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
    func fetchUserLikeData(completion: @escaping ([LikeData]?) -> Void) {
        let userRef = db.collection("users").document(user.id)
        let likeCollection = userRef.collection("likeCollection")
        
        likeCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching LikeData: \(error)")
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

                 self.likeDelegate?.manager(self, didGet: userLikes)
                completion(userLikes)
 
            }
        }
    }

    // ---------------------------------------------------
    func fetchConcertData() {
        let artDataCollection = db.collection("concert")
        
        artDataCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching ConcertData: \(error)")
                return
            }
            
            var artDataArray: [ArtDatum] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                if let uid = data["UID"] as? String,
                   let title = data["title"] as? String,
                   let category = data["category"] as? String,
                   let descriptionFilterHTML = data["descriptionFilterHtml"] as? String,
                   let imageURL = data["imageUrl"] as? String,
                   imageURL != "",
                   let webSales = data["webSales"] as? String,
                   let startDate = data["startDate"] as? String,
                   let endDate = data["endDate"] as? String,
                   let hitRate = data["hitRate"] as? Int,
                   let showInfoArray = data["showInfo"] as? [[String: Any]] {
                    
                    var showInfo: [ShowInfo] = []
                    
                    for showInfoData in showInfoArray {
                        if let time = showInfoData["time"] as? String,
                           let location = showInfoData["location"] as? String,
                           let locationName = showInfoData["locationName"] as? String,
                           let price = showInfoData["price"] as? String,
                           let endTime = showInfoData["endTime"] as? String {
                            
                            let latitude = showInfoData["latitude"] as? String
                            let longitude = showInfoData["longitude"] as? String
                            
                            let singleShowInfo = ShowInfo(time: time, location: location, locationName: locationName, price: price, latitude: latitude, longitude: longitude, endTime: endTime)
                            showInfo.append(singleShowInfo)
                        }
                    }
                    
                    let concertData = ArtDatum(uid: uid, title: title, category: category, showInfo: showInfo, descriptionFilterHTML: descriptionFilterHTML, imageURL: imageURL, webSales: webSales, startDate: startDate, endDate: endDate, hitRate: hitRate)
                    artDataArray.append(concertData)
                }
                
                self.concertDelegate?.manager(self, didGet: artDataArray)
            }
        }
    }
    
    // ---------------------------------------------------
}
