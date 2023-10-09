//
//  ArtDatum.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation

// MARK: - Datum
struct ArtDatum: Codable {
    let uid, title, category: String
    let showInfo: [ShowInfo]
    let descriptionFilterHTML: String
    let imageURL: String
    let webSales: String
    let sourceWebPromote: String
    let startDate, endDate: String
    let hitRate: Int
    
        enum CodingKeys: String, CodingKey {
            case uid = "UID"
            case title, category, showInfo
            case descriptionFilterHTML = "descriptionFilterHtml"
            case imageURL = "imageUrl"
            case webSales, sourceWebPromote, startDate, endDate, hitRate
        }
}

// MARK: - ShowInfo
struct ShowInfo: Codable {
    let time, location, locationName: String
    let price: String
    let latitude, longitude: String?
    let endTime: String
}
