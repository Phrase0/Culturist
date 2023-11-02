//
//  BookShopManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation
import Alamofire

protocol BookShopManagerDelegate: AnyObject {
    func manager(_ manager: BookShopManager, didGet BookShopList: [BookShop])
    func manager(_ manager: BookShopManager, didFailWith error: Error)
}

class BookShopManager {
    
    weak var delegate: BookShopManagerDelegate?
    
    func loadBookShops() {
        // ask for coffeeShop request
        // testMode: less"h" in the baseUrl now
        let baseUrl = "https://cloud.culture.tw/frontsite/trans/emapOpenDataAction.do?method=exportEmapJson&typeId=M"
        AF.request(baseUrl).responseDecodable(of: [BookShop].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                self?.delegate?.manager(self!, didGet: data)
            case .failure(let error):
                self?.delegate?.manager(self!, didFailWith: error)
                print("Error fetching coffee shop data: \(error)")
                self?.getBookShopsListFromAsset(filename: JsonName.bookshop.rawValue)
                print("success use book local data")
            }
        }
    }
    
    // if api fetch failure
    func getBookShopsListFromAsset(filename: String) {
        let jsonData: [BookShop] = load(filename)
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
