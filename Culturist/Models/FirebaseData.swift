//
//  FirebaseData.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import Foundation

struct FirebaseData {
    let user: [User]
}

struct User {
    let id: String
    let name: String
    let email: String
    let recommendationData: [RecommendationData]
    let likeData: [LikeData]
}

struct RecommendationData: Hashable {
    let exhibitionUid: String
    let title: String
    let category: String
    let location: String
    let locationName: String
    
    // provide hash
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(exhibitionUid)
//        hasher.combine(title)
//        hasher.combine(category)
//        hasher.combine(location)
//        hasher.combine(locationName)
//    }
//    
//    static func == (lhs: RecommendationData, rhs: RecommendationData) -> Bool {
//        return lhs.exhibitionUid == rhs.exhibitionUid &&
//        lhs.title == rhs.title &&
//        lhs.category == rhs.category &&
//        lhs.location == rhs.location &&
//        lhs.locationName == rhs.locationName
//    }
}

struct LikeData {
    let exhibitionUid: String?
    let coffeeShopUid:String?
    let bookShopUid:String?
}
