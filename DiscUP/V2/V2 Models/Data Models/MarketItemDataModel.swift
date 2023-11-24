//
//  MarketItemDataModel.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 1/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

//  MARK: - MarketItemDataModel

struct MarketItemDataModel: Codable {
    @DocumentID var id: String?
    
    var headline: String
    var manufacturer: String
    var model: String
    var plastic: String
    var weight: Double
    var thumbImageID: String
    var price: Int
    var geohash: String
    var lat: Double
    var long: Double
    var itemType: MarketItemV2Type
    var description: String
    var sellerID: String
    var imageIDs: [String]
    var listDate: Double
    
    init?(_ item: MarketItemV2) async {
        guard let geohash = await LocationManager.shared.createHash(zip: item.location.zipCode) else { return nil }
        
        id = item.id
        headline = item.headline
        manufacturer = item.manufacturer
        model = item.model
        plastic = item.plastic
        weight = item.weight
        thumbImageID = item.thumbImageID
        price = item.price
        self.geohash = geohash
        lat = item.location.latitude
        long = item.location.longitude
        itemType = item.itemType
        description = item.description
        sellerID = item.seller.userID
        imageIDs = item.imageIDs
        listDate = item.listDate.timeIntervalSince1970
    }
}

// MARK: - MarketItemV2Type

enum MarketItemV2Type: String, CaseIterable, Codable {
    case disc = "Disc"
    case bag = "Bag"
    case basket = "Basket"
}

extension MarketItemV2 {
    convenience init?(_ itemDataModel: MarketItemDataModel) {
        guard let id = itemDataModel.id else { return nil }
        
        let appUser = AppUser(userID: itemDataModel.sellerID)
        
        self.init(
            id: id,
            headline: itemDataModel.headline,
            manufacturer: itemDataModel.manufacturer,
            model: itemDataModel.model,
            plastic: itemDataModel.plastic,
            weight: itemDataModel.weight,
            thumbImageID: itemDataModel.thumbImageID,
            price: itemDataModel.price,
            location: Location(latitude: itemDataModel.lat, longitude: itemDataModel.long),
            itemType: itemDataModel.itemType,
            description: itemDataModel.description,
            seller: appUser,
            imageIDs: itemDataModel.imageIDs,
            images: [],
            listDate: Date(timeIntervalSince1970: itemDataModel.listDate)
        )
    }
}
