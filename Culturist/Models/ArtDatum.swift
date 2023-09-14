//
//  ArtDatum.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation

// MARK: - Datum
struct ArtDatum: Codable {
    let version, uid, title, category: String
    let showInfo: [ShowInfo]
    let showUnit, discountInfo: String
    let descriptionFilterHTML: String
    let imageURL: String
    let masterUnit, subUnit, supportUnit, otherUnit: [String]
    let webSales: String
    let sourceWebPromote: String
    let comment: String
    let editModifyDate: String
    let sourceWebName, startDate, endDate: String
    let hitRate: Int
    
        enum CodingKeys: String, CodingKey {
            case version
            case uid = "UID"
            case title, category, showInfo, showUnit, discountInfo
            case descriptionFilterHTML = "descriptionFilterHtml"
            case imageURL = "imageUrl"
            case masterUnit, subUnit, supportUnit, otherUnit, webSales, sourceWebPromote, comment, editModifyDate, sourceWebName, startDate, endDate, hitRate
        }
}

// MARK: - ShowInfo
struct ShowInfo: Codable {
    let time, location, locationName: String
    let onSales: String
    let price: String
    let latitude, longitude: String?
    let endTime: String
}
