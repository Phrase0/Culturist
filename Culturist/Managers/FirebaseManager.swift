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

class FirebaseManager {
    
    var collectionDelegate:FirebaseCollectionDelegate?
    var likeDelegate: FirebaseLikeDelegate?
    
    // Get the Firestore database reference
    let db = Firestore.firestore()
    
    // MARK: - UserData
    func addUserData(id: String, fullName: String?, email: String?) {
        // Use id as the document identifier
        let document = db.collection("users").document(id)
        // Use the getDocument method to check if the document already exists
        document.getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to retrieve the document: \(error.localizedDescription)")
                return
            }
            // ---------------------------------------------------
            // If the document exists, update the data
            if snapshot?.exists == true {
                var updatedData: [String: Any] = [:]
                
                // Check if fullName is not empty and not just whitespace
                if let fullName = fullName, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    updatedData["fullName"] = fullName
                }
                
                // Update email if it's not nil
                if let email = email {
                    updatedData["email"] = email
                }
                
                // Update createdTime (if needed)
                updatedData["createdTime"] = FieldValue.serverTimestamp()
                
                document.updateData(updatedData) { error in
                    if let error = error {
                        print("Failed to update data: \(error.localizedDescription)")
                    } else {
                        print("Data updated successfully")
                    }
                }
            }
        
            // ---------------------------------------------------
            // If the document doesn't exist, add new data
            if snapshot?.exists == false {
                let data: [String: Any] = [
                    "id": id as Any,
                    "fullName": fullName as Any,
                    "email": email as Any,
                    "createdTime": FieldValue.serverTimestamp()
                ]
                
                document.setData(data) { error in
                    if let error = error {
                        print("Failed to add data: \(error.localizedDescription)")
                    } else {
                        print("Data added successfully")
                    }
                }
            }
        }
    }
    
    func removeUserData() {
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
        let recommendationDataCollection = userRef.collection("recommendationData")

        recommendationDataCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
        let likeCollection = userRef.collection("likeCollection")
        likeCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }

    // MARK: - Recommendation
    func addRecommendData(exhibitionUid: String, title: String, location: String, locationName: String) {
        // Create a new RecommendationData
        let newRecommendationData = RecommendationData(exhibitionUid: exhibitionUid, title: title, location: location, locationName: locationName)
        // Get the user's document reference
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
    }
    
    
    // ---------------------------------------------------
    func readRecommendationData() {
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
    }
    
    // ---------------------------------------------------
    func removeLikeData(likeData: LikeData) {
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
        let userRef = db.collection("users").document(KeychainItem.currentUserIdentifier)
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
    
}
