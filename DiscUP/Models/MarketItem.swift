//
//  MarketItem.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/11/21.
//

import Foundation
import FirebaseDatabase
import UIKit

class MarketItem {
    let id: String
    let headline: String
    let manufacturer: String
    let model: String
    let plastic: String?
    let weight: Double?
    let description: String
    let imageIDs: [String]
    let thumbImageID: String
    let askingPrice: Int?
    let sellingLocation: Location
    let updatedTimestamp: Date
    let inputZipCode: String?
    let ownerID: String?
    
    init(id: String = UUID().uuidString, headline: String, manufacturer: String, model: String, plastic: String?, weight: Double?, description: String, imageIDs: [String], thumbImageID: String, askingPrice: Int?, sellingLocation: Location, updatedTimestamp: Date, inputZipCode: String?, ownerID: String?) {
        self.id = id
        self.headline = headline
        self.manufacturer = manufacturer
        self.model = model
        self.plastic = plastic
        self.weight = weight
        self.description = description
        self.imageIDs = imageIDs
        self.thumbImageID = thumbImageID
        self.askingPrice = askingPrice
        self.sellingLocation = sellingLocation
        self.updatedTimestamp = updatedTimestamp
        self.inputZipCode = inputZipCode
        self.ownerID = ownerID
    }
    
    convenience init(itemID: String, itemSnap: DataSnapshot) {
        let description                 = itemSnap.childSnapshot(forPath: MarketKeys.description).value as? String ?? "(description)"
        let headline                    = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
        let manufacturer                = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
        let model                       = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
        let plastic                     = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
        var weight                      = itemSnap.childSnapshot(forPath: MarketKeys.weight).value as? Double
        let imageIDsString              = itemSnap.childSnapshot(forPath: MarketKeys.imageIDs).value as? String ?? ""
        let thumbImageID                = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
        var askingPrice                 = itemSnap.childSnapshot(forPath: MarketKeys.askingPrice).value as? Int
        let sellingLocation             = itemSnap.childSnapshot(forPath: MarketKeys.sellingLocation).value as? String ?? "Unknown Location"
        let updatedTimestampString      = itemSnap.childSnapshot(forPath: MarketKeys.updatedTimestamp).value as? String
        let inputZipCode                = itemSnap.childSnapshot(forPath: MarketKeys.inputZipCode).value as? String
        let ownerID                     = itemSnap.childSnapshot(forPath: MarketKeys.owner).value as? String
        
        let imageIDs = imageIDsString.components(separatedBy: ",")
        
        if askingPrice == 0 { askingPrice = nil }
        if weight == 0 { weight = nil }
        
        let updatedTimestamp = updatedTimestampString?.stringToLocalDate(format: .fullNumericWithTimezone) ?? Date.distantPast
        
        let sellingLocationArray = sellingLocation.split(separator: ",")
        
        let location = Location(latitude: Double(sellingLocationArray[0]) ?? 0, longitude: Double(sellingLocationArray[1]) ?? 0)
        
        self.init(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description, imageIDs: imageIDs, thumbImageID: thumbImageID, askingPrice: askingPrice, sellingLocation: location, updatedTimestamp: updatedTimestamp, inputZipCode: inputZipCode, ownerID: ownerID)
    }
}

struct MarketItemBasic {
    let id: String
    let headline: String
    let manufacturer: String
    let model: String
    let plastic: String?
    let thumbImageID: String
}
