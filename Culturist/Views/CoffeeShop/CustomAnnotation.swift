//
//  CustomAnnotation.swift
//  Culturist
//
//  Created by Peiyun on 2023/10/15.
//

import UIKit
import MapKit
// MARK: - CustomAnnotation
// for exhibitionLocation pincolor
class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var pinColor: UIColor
    
    init(coordinate: CLLocationCoordinate2D, title: String?, pinColor: UIColor) {
        self.coordinate = coordinate
        self.title = title
        self.pinColor = pinColor
    }
}
