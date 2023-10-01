//
//  ArtManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import Foundation
import Alamofire

protocol ArtManagerDelegate {
    func manager(_ manager: ArtProductManager, didGet artProductList: [ArtDatum])
    func manager(_ manager: ArtProductManager, didFailWith error: Error)
}

class ArtProductManager {
    var delegate:ArtManagerDelegate?
    
    func getArtProductList(number:String) {
        // testMode: less"h" in the baseUrl now
        let urlString = "https://cloud.culture.tw/frontsite/opendata/activityOpenDataJsonAction.do?method=doFindActivitiesByCategory&category=\(number)"
        AF.request(urlString).responseDecodable(of: [ArtDatum].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                let filteredData = data.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
                self?.delegate?.manager(self!, didGet: filteredData)
            case .failure(let error):
                self?.delegate?.manager(self!, didFailWith: error)
                 print("Error fetching JSON data: \(error)")
                if number == "1" {
                    self?.getArtProductListFromAsset(filename: JsonName.concert.rawValue)
                    
                } else {
                    self?.getArtProductListFromAsset(filename: JsonName.exhibition.rawValue)
                }
                print("success use artProduct local data")
            }
        }
    }
    
    // if api fetch failure
    func getArtProductListFromAsset(filename: String) {
        let jsonData: [ArtDatum] = load(filename)
        let filteredData = jsonData.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
        self.delegate?.manager(self, didGet: filteredData)
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
