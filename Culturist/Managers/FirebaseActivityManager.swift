//
//  FirebaseActivityManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/28.
//

protocol FirebaseConcertDelegate {
    func manager(_ manager: ConcertDataManager, didGet concertData: [ArtDatum])
    func manager(_ manager: ConcertDataManager, didFailWith error: Error)
}

protocol FirebaseExhibitionDelegate {
    func manager(_ manager: ExhibitionDataManager, didGet exhibitionData: [ArtDatum])
    func manager(_ manager: ExhibitionDataManager, didFailWith error: Error)
}

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - ConcertDataManager
class ConcertDataManager {
    var concertDelegate: FirebaseConcertDelegate?
    // get firebase data(local method)
    func fetchConcertData() {
        let db = Firestore.firestore()
        let artDataCollection = db.collection("concert")
        
        artDataCollection.whereField("imageUrl", isNotEqualTo: "").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching ConcertData: \(error)")
                self.concertDelegate?.manager(self, didFailWith: error)
                return
            }
            
            var artDataArray: [ArtDatum] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                if let uid = data["UID"] as? String,
                   let title = data["title"] as? String,
                   let category = data["category"] as? String,
                   let descriptionFilterHTML = data["descriptionFilterHtml"] as? String,
                   let imageURL = data["imageUrl"] as? String,
                   let webSales = data["webSales"] as? String,
                   let sourceWebPromote = data["sourceWebPromote"] as? String,
                   let startDate = data["startDate"] as? String,
                   let endDate = data["endDate"] as? String,
                   let hitRate = data["hitRate"] as? Int,
                   let showInfoArray = data["showInfo"] as? [[String: Any]] {
                    
                    var showInfo: [ShowInfo] = []
                    
                    for showInfoData in showInfoArray {
                        if let time = showInfoData["time"] as? String,
                           let location = showInfoData["location"] as? String,
                           let locationName = showInfoData["locationName"] as? String,
                           let price = showInfoData["price"] as? String,
                           let endTime = showInfoData["endTime"] as? String {
                            let latitude = showInfoData["latitude"] as? String
                           let longitude = showInfoData["longitude"] as? String
                            
                            let singleShowInfo = ShowInfo(time: time, location: location, locationName: locationName, price: price, latitude: latitude, longitude: longitude, endTime: endTime)
                            showInfo.append(singleShowInfo)
                        }
                    }
                    
                    let concertData = ArtDatum(uid: uid, title: title, category: category, showInfo: showInfo, descriptionFilterHTML: descriptionFilterHTML, imageURL: imageURL, webSales: webSales, sourceWebPromote: sourceWebPromote, startDate: startDate, endDate: endDate, hitRate: hitRate)
                    artDataArray.append(concertData)
                }
                
                self.concertDelegate?.manager(self, didGet: artDataArray)
            }
        }
    }
}

// MARK: - ExhibitionDataManager
class ExhibitionDataManager {
    var exhibitionDelegate: FirebaseExhibitionDelegate?
    
    func fetchExhibitionData() {
        let db = Firestore.firestore()
        let artDataCollection = db.collection("exhibition")
        
        artDataCollection.whereField("imageUrl", isNotEqualTo: "").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching ConcertData: \(error)")
                self.exhibitionDelegate?.manager(self, didFailWith: error)
                return
            }
            
            var artDataArray: [ArtDatum] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                if let uid = data["UID"] as? String,
                   let title = data["title"] as? String,
                   let category = data["category"] as? String,
                   let descriptionFilterHTML = data["descriptionFilterHtml"] as? String,
                   let imageURL = data["imageUrl"] as? String,
                   let webSales = data["webSales"] as? String,
                   let sourceWebPromote = data["sourceWebPromote"] as? String,
                   let startDate = data["startDate"] as? String,
                   let endDate = data["endDate"] as? String,
                   let hitRate = data["hitRate"] as? Int,
                   let showInfoArray = data["showInfo"] as? [[String: Any]] {
                    
                    var showInfo: [ShowInfo] = []
                    
                    for showInfoData in showInfoArray {
                        if let time = showInfoData["time"] as? String,
                           let location = showInfoData["location"] as? String,
                           let locationName = showInfoData["locationName"] as? String,
                           let price = showInfoData["price"] as? String,
                           let endTime = showInfoData["endTime"] as? String {
                            
                            let latitude = showInfoData["latitude"] as? String
                            let longitude = showInfoData["longitude"] as? String
                            
                            let singleShowInfo = ShowInfo(time: time, location: location, locationName: locationName, price: price, latitude: latitude, longitude: longitude, endTime: endTime)
                            showInfo.append(singleShowInfo)
                        }
                    }
                    
                    let exhibitionData = ArtDatum(uid: uid, title: title, category: category, showInfo: showInfo, descriptionFilterHTML: descriptionFilterHTML, imageURL: imageURL, webSales: webSales, sourceWebPromote: sourceWebPromote, startDate: startDate, endDate: endDate, hitRate: hitRate)
                    artDataArray.append(exhibitionData)
                }
                
                self.exhibitionDelegate?.manager(self, didGet: artDataArray)
            }
        }
    }
}
