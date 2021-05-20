//
//  MarketItem.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/11/21.
//

import Foundation
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
}

struct MarketItemBasic {
    let id: String
    let headline: String
    let manufacturer: String
    let model: String
    let plastic: String?
    let thumbImageID: String
}
