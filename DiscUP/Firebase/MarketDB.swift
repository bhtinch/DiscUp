//
//  MarketDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

struct MarketKeys {
    static let conversations = "conversations"
    static let owner = "owner"
    static let headline = "headline"
    static let manufacturer = "manufacturer"
    static let model = "model"
    static let plastic = "plastic"
    static let weight = "weight"
    static let description = "description"
    static let images = "images"
}

class MarketDB {
    static let shared = MarketDB()
    let dbRef = Database.database(url: "https://discup-market-rtdb.firebaseio.com/").reference()
}   //  End of Class
