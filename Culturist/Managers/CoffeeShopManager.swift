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
        // testMode: less"h" in the baseUrl now
        let baseUrl = "ttps://cafenomad.tw/api/v1.2/cafes"
        
        AF.request(baseUrl).responseDecodable(of: [CoffeeShop].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                self?.delegate?.manager(self!, didGet: data)
            case .failure(let error):
                self?.delegate?.manager(self!, didFailWith: error)
                print("Error fetching coffee shop data: \(error)")
                self?.getCoffeeShopsListFromAsset(filename: JsonName.coffeeshop.rawValue)
                print("success use coffee local data")
            }
        }
    }
    
    // if api fetch failure
    func getCoffeeShopsListFromAsset(filename: String) {
        let jsonData: [CoffeeShop] = load(filename)
        self.delegate?.manager(self, didGet: jsonData)
    }

    func load<T: Decodable>(_ filename: String) -> T {
        guard let data = NSDataAsset(name: filename)?.data else {
            fatalError("Couldn't load \(filename) from asset")
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
}
