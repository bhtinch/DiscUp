//
//  Bag.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import Foundation

class Bag {
    var name: String
    var brand: String?
    var model: String?
    var color: String?
    var discs: [Disc]
    var discIDs: [String : String]
    var isDefault: Bool
    var uuidString: String
    
    init(name: String, brand: String?, model: String?, color: String?, discs: [Disc] = [], discIDs: [String : String] = [:], isDefault: Bool = false, uuidString: String = UUID().uuidString) {
        self.name = name
        self.brand = brand
        self.model = model
        self.color = color
        self.discs = discs
        self.discIDs = discIDs
        self.isDefault = isDefault
        self.uuidString = uuidString
    }
}
