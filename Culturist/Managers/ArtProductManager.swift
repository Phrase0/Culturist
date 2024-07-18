//
//  ArtManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Combine

protocol ArtManagerDelegate: AnyObject {
    func manager(_ manager: ArtProductManager, didGet artProductList: [ArtDatum])
    func manager(_ manager: ArtProductManager, didFailWith error: Error)
}

class ArtProductManager {
    
    weak var delegate: ArtManagerDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    func getArtProductList(number: String) {
        let urlString = "https://cloud.culture.tw/frontsite/opendata/activityOpenDataJsonAction.do?method=doFindActivitiesByCategory&category=\(number)"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Culturist", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            self.delegate?.manager(self, didFailWith: error)
            return
        }
        
        if let cachedData = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            if let artProductList = try? JSONDecoder().decode([ArtDatum].self, from: cachedData.data) {
                filterAndNotify(artProductList)
                return
            }
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                let cachedData = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: url))
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
                }
            }, receiveValue: { [weak self] artProductList in
                self?.filterAndNotify(artProductList)
            })
            .store(in: &cancellables)
    }
    
    private func filterAndNotify(_ artProductList: [ArtDatum]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredData = artProductList.filter { !$0.imageURL.isEmpty && $0.uid != "645357a031bef61dcaf57d5c" }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.manager(self, didGet: filteredData)
            }
        }
    }
    
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
