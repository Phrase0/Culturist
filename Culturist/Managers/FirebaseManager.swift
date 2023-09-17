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
    let user = User(id: "user_id", name: "user_name", email: "user_email", recommendationData: [])
    
    func addData(exhibitionUid: String) {
        // Create a new RecommendationData
        let newRecommendationData = RecommendationData(exhibitionUid: exhibitionUid)
        // Get the user's document reference
        let userRef = db.collection("users").document(user.id)
        // Add RecommendationData to the user's document data
        let data: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "recommendationData": FieldValue.arrayUnion([["exhibitionUid": newRecommendationData.exhibitionUid]])
        ]
        
        // Set the user's document data with merge option to update existing data
        userRef.setData(data, merge: true) { (error) in
            if let error = error {
                print("Error adding RecommendationData: \(error)")
            } else {
                print("RecommendationData added successfully.")
            }
        }
    }
    
    // ---------------------------------------------------
    func readExhibitionUid() {
           // Get the user's document reference
           let userRef = db.collection("users").document(user.id)

           // read data
           userRef.getDocument { (documentSnapshot, error) in
               if let error = error {
                   self.collectionDelegate?.manager(self, didFailWith: error)
                   print("Error fetching user document: \(error)")
                   return
               }

               if let document = documentSnapshot, document.exists {
                   // if user document exists
                   let userData = document.data()

                   // read recommendationData array
                   if let recommendationDataArray = userData?["recommendationData"] as? [[String: Any]] {
                       var recommendationList = [RecommendationData]()

                       for recommendationDataDict in recommendationDataArray {
                           if let exhibitionUid = recommendationDataDict["exhibitionUid"] as? String {
                               print("Exhibition UID: \(exhibitionUid)")
                               // add RecommendationData to recommendationList
                               let recommendationData = RecommendationData(exhibitionUid: exhibitionUid)
                               recommendationList.append(recommendationData)
                           }
                       }
                       self.collectionDelegate?.manager(self, didGet: recommendationList)
                   } else {
                       print("recommendationData array not found in user document.")
                   }
               } else {
                   print("User document does not exist.")
               }
           }
       }
    
    // ---------------------------------------------------
    
}
