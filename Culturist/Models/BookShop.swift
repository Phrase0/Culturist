//
//  BookShop.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation

struct BookShop: Codable {
    let name: String
    let representImage: String
    let intro: String
    let address: String
    let longitude, latitude: String
    let openTime: String
    let phone: String
    let email: String
    let headCityName: String
    let nameEng, introEng: String
    let mainTypeName: String
    let cityName: String
    let groupTypeName: String
    let mainTypePk, version: String
    let hitRate: Int
    let type: String?

    enum CodingKeys: String, CodingKey {
        case name, representImage, intro, address, longitude, latitude, openTime, phone, email, headCityName
        case nameEng = "name_eng"
        case introEng = "intro_eng"
        case mainTypeName, cityName, groupTypeName, mainTypePk, version, hitRate, type
    }
}


