//
//  BookShopManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation
import Alamofire

protocol BookShopManagerDelegate {
    func manager(_ manager: BookShopManager, didGet BookShopList: [BookShop])
    func manager(_ manager: BookShopManager, didFailWith error: Error)
}

class BookShopManager {
    
    var delegate: BookShopManagerDelegate?
    
    func loadBookShops() {
        // ask for coffeeShop request
        let baseUrl = "https://cloud.culture.tw/frontsite/trans/emapOpenDataAction.do?method=exportEmapJson&typeId=M"
        AF.request(baseUrl).responseDecodable(of: [BookShop].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                self?.delegate?.manager(self!, didGet: data)
            case .failure(let error):
                self?.delegate?.manager(self!, didFailWith: error)
                print("Error fetching coffee shop data: \(error)")
            }
        }
    }
    
}
