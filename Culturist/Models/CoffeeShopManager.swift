//
//  CoffeeShopManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation
import Alamofire

protocol CoffeeShopManagerDelegate {
    func manager(_ manager: CoffeeShopManager, didGet CoffeeShopList: [CoffeeShop])
    func manager(_ manager: CoffeeShopManager, didFailWith error: Error)
}

class CoffeeShopManager {
    
    var delegate: CoffeeShopManagerDelegate?
    
    func loadCoffeeShops() {
        // ask for coffeeShop request
        let baseUrl = "https://cafenomad.tw/api/v1.2/cafes"
        
        AF.request(baseUrl).responseDecodable(of: [CoffeeShop].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                self?.delegate?.manager(self!, didGet: data)
            case .failure(let error):
                print("Error fetching coffee shop data: \(error)")
            }
        }
    }
    
}
