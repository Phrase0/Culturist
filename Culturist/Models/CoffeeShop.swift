//
//  CoffeeShop.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation

struct CoffeeShop: Codable {
    let id, name: String
    let city: String
    let wifi, seat, quiet, tasty: Double
    let cheap, music: Double
    let url: String
    let address: String
    let latitude, longitude: String
    let limitedTime, socket, standingDesk: String
    let mrt: String
    let openTime: String

    enum CodingKeys: String, CodingKey {
        case id, name, city, wifi, seat, quiet, tasty, cheap, music, url, address, latitude, longitude
        case limitedTime = "limited_time"
        case socket
        case standingDesk = "standing_desk"
        case mrt
        case openTime = "open_time"
    }
}
