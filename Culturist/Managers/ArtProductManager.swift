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
        let urlString = "https://cloud.culture.tw/frontsite/opendata/activityOpenDataJsonAction.do?method=doFindActivitiesByCategory&category=\(number)"
        AF.request(urlString).responseDecodable(of: [ArtDatum].self) {
            [weak self] response in
            switch response.result {
            case .success(let data):
                //let filteredData = data.filter { $0.showInfo[0].latitude != nil && $0.showInfo[0].longitude != nil && !$0.imageURL.isEmpty }
                let filteredData = data.filter { !$0.imageURL.isEmpty }
                self?.delegate?.manager(self!, didGet: filteredData)
                
            case .failure(let error):
                self?.delegate?.manager(self!, didFailWith: error)
                print("Error fetching JSON data: \(error)")
                
            }
        }
    }
}
