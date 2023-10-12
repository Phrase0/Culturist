//
//  EventKitExt.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/21.
//

import UIKit
import EventKit

extension EKEvent {
    var hasGeoLocation: Bool {
        return structuredLocation?.geoLocation != nil
    }
    
    var isBirthdayEvent: Bool {
        return birthdayContactIdentifier != nil
    }
    
    var color: UIColor {
        if let calendarColor = calendar?.cgColor {
            return UIColor(cgColor: calendarColor)
        } else {
            return UIColor.GR2!
        }
    }

}
