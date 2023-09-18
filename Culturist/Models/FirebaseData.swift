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
}

struct RecommendationData {
    let exhibitionUid: String
    let title: String
    let location: String
    let locationName: String
}
