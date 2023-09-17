//
//  FirebaseManager.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/17.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {

    let products = Firestore.firestore().collection("products")
    
    func addData(exhibitionUid:String?) {
        let document = products.document()
        let data: [String: Any] = [
            "exhibitionUid": exhibitionUid as Any,
            "createdTime": Date().timeIntervalSince1970,
            "id": document.documentID
        ]
        document.setData(data)
    }
    
    func fetchData() {
        products.order(by: "createdTime", descending: true).addSnapshotListener { [weak self] (querySnapshot, error) in
            //清空data資料
//            self?.myData = []
            if let error = error {
                print("There was an issue retrieving data from Firestore, \(error)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for document in snapshotDocuments {
                        let data = document.data()
                        if let exhibitionUid = data["exhibitionUid"] as? String,
                           let createdTime = data["createdTime"] as? TimeInterval,
                           let id = data["id"] as? String {
                            let newData = RecommendationData(exhibitionUid: exhibitionUid, createdTime: createdTime, id: id)
                            //self?.myData.append(newData)
                        }
                        
                        DispatchQueue.main.async {
                            //self?.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
}


struct RecommendationData {
    let exhibitionUid: String
    let createdTime: TimeInterval
    let id: String
}
