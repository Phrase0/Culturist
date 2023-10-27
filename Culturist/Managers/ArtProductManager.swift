//
//  ArtManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Combine
import Alamofire
protocol ArtManagerDelegate {
    func manager(_ manager: ArtProductManager, didGet artProductList: [ArtDatum])
    func manager(_ manager: ArtProductManager, didFailWith error: Error)
}

class ArtProductManager {
    
    var delegate: ArtManagerDelegate?
    
//    func getArtProductList(number:String) {
//        let urlString = "https://cloud.culture.tw/frontsite/opendata/activityOpenDataJsonAction.do?method=doFindActivitiesByCategory&category=\(number)"
//        AF.request(urlString).responseDecodable(of: [ArtDatum].self) {
//            [weak self] response in
//            switch response.result {
//            case .success(let data):
//                let filteredData = data.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
//                self?.delegate?.manager(self!, didGet: filteredData)
//            case .failure(let error):
//                self?.delegate?.manager(self!, didFailWith: error)
//                 print("Error fetching JSON data: \(error)")
//                if number == "1" {
//                    self?.getArtProductListFromAsset(filename: JsonName.concert.rawValue)
//
//                } else {
//                    self?.getArtProductListFromAsset(filename: JsonName.exhibition.rawValue)
//                }
//                print("success use artProduct local data")
//            }
//        }
//    }
    
    private var cancellables: Set<AnyCancellable> = []

    func getArtProductList(number: String) {
        let urlString = "https://cloud.culture.tw/frontsite/opendata/activityOpenDataJsonAction.do?method=doFindActivitiesByCategory&category=\(number)"

        if let cachedData = URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: urlString)!)) {
            // Use cached data if available
            if let artProductList = try? JSONDecoder().decode([ArtDatum].self, from: cachedData.data) {
                let filteredData = artProductList.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
                delegate?.manager(self, didGet: filteredData)
                return
            }
        }

        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .tryMap { data, response in
                // Cache the response
                let cachedData = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: URL(string: urlString)!))
                return data
            }
            .decode(type: [ArtDatum].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.delegate?.manager(self, didFailWith: error)
                    print("Error fetching JSON data: \(error)")

                    if number == "1" {
                        self.getArtProductListFromAsset(filename: JsonName.concert.rawValue)
                    } else {
                        self.getArtProductListFromAsset(filename: JsonName.exhibition.rawValue)
                    }
                    print("Using cached artProduct local data")
                }
            }, receiveValue: { artProductList in
                let filteredData = artProductList.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
                self.delegate?.manager(self, didGet: filteredData)
            })
            .store(in: &cancellables)
    }

    // Helper function to clear the cache
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
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
