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
}

struct LikeData {
    let exhibitionUid: String?
    let coffeeShopUid:String?
    let bookShopUid:String?
}
