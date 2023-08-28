//
//  Default.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/17/23.
//

import Foundation

enum Default: String {
    case userID
    case userDisplayName
    case userAvatarImage
    case defaultSellingLocationLat
    case defaultSellingLocationLong
    
    private var userDefaults: UserDefaults {
        UserDefaults.standard
    }
    
    var value: Any? {
        userDefaults.object(forKey: self.rawValue)
    }
    
    func updateValue(_ value: Any?) {
        userDefaults.set(value, forKey: self.rawValue)
    }
}
