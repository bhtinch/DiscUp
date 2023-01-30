//
//  MarketDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import FirebaseDatabase

struct MarketKeys {
    static let conversations = "conversations"
    static let owner = "owner"
    static let headline = "headline"
    static let manufacturer = "manufacturer"
    static let model = "model"
    static let plastic = "plastic"
    static let weight = "weight"
    static let description = "description"
    static let imageIDs = "imageIDs"
    static let thumbImageID = "thumbImageID"
    static let askingPrice = "askingPrice"
    static let sellingLocation = "sellingLocation"
    static let updatedTimestamp = "updatedTimestamp"
    static let inputZipCode = "inputZipCode"
    static let coordinates = "coordinates"
    static let latitude = "latitude"
    static let longitude = "longitude"
}

class MarketDB {
    static let shared = MarketDB()
    let dbRef = Database.database(url: "https://discup-market-rtdb.firebaseio.com/").reference()
}   //  End of Class
