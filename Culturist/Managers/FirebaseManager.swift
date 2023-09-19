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
        print("Hi")
    }
}
