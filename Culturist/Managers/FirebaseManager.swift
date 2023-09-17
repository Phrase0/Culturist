//
//  FirebaseManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {

    let userData = Firestore.firestore().collection("user")
    
    func addData(exhibitionUid: String) {
        // Create a new RecommendationData
        let newRecommendationData = RecommendationData(exhibitionUid: exhibitionUid)
        // Get the Firestore database reference
        let db = Firestore.firestore()
        // Assuming a User object
        let user = User(id: "user_id", name: "user_name", email: "user_email", recommendationData: [])
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


}
