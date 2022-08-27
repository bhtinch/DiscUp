//
//  MarketItemV2.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit

// MARK: - MarketItemV2Type

enum MarketItemV2Type: String, CaseIterable {
    case disc = "Disc"
    case bag = "Bag"
    case basket = "Basket"
}

// MARK: - MarketItemEditableValue

enum MarketItemV2EditableValue {
    case headline, manufacturer, model, plastic, thumbImageID, price, location, itemType, description, imageIDs
}

// MARK: - MarketItemV2

struct MarketItemV2 {
    
    //  MARK: - Properties
    
    let id: String
    
    var headline: String
    var manufacturer: String
    var model: String
    var plastic: String?
    var weight: Double?
    var thumbImageID: String
    var price: Int
    var location: Location
    var itemType: MarketItemV2Type
    var description: String
    var seller: AppUser
    var imageIDs: [String]
    var images: [MarketImage]
    
    //  MARK: - Initialization
    
    init(
        id: String,
        headline: String,
        manufacturer: String,
        model: String,
        plastic: String? = nil,
        weight: Double? = nil,
        thumbImageID: String,
        price: Int,
        location: Location,
        itemType: MarketItemV2Type,
        description: String = "No description provided.",
        seller: AppUser = AppUser.users[1],
        imageIDs: [String] = [],
        images: [MarketImage] = []
    ) {
        self.id = id
        self.headline = headline
        self.manufacturer = manufacturer
        self.model = model
        self.plastic = plastic
        self.weight = weight
        self.thumbImageID = thumbImageID
        self.price = price
        self.location = location
        self.itemType = itemType
        self.description = description
        self.seller = seller
        self.imageIDs = imageIDs
        self.images = images
    }
    
    init?(marketItem: MarketItem, type: MarketItemV2Type) {
        guard
            let ownerID = marketItem.ownerID,
            let price = marketItem.askingPrice
        else { return nil }
        
        self.init(
            id: marketItem.id,
            headline: marketItem.headline,
            manufacturer: marketItem.manufacturer,
            model: marketItem.model,
            plastic: marketItem.plastic,
            weight: marketItem.weight,
            thumbImageID: marketItem.thumbImageID,
            price: price,
            location: marketItem.sellingLocation,
            itemType: type,
            description: marketItem.description,
            seller: AppUser(userID: ownerID)
            )
    }
    
    //  MARK: - DefaultNoItem
    
    static var defaultNoItem: MarketItemV2 = MarketItemV2(
        id: UUID().uuidString,
        headline: "No Item Selected",
        manufacturer: "N/A",
        model: "N/A",
        plastic: "N/A",
        thumbImageID: "N/A",
        price: 25,
        location: Location(latitude: 222, longitude: 333),
        itemType: .disc
        )
    
    //  MARK: - Dummy Data
    
    private static var usedItems: [MarketItemV2] {
        var arr = [MarketItemV2]()
        
        for i in 1...10 {
            arr.append(
                MarketItemV2(
                    id: UUID().uuidString,
                    headline: "Used Item \(i)",
                    manufacturer: "Innova",
                    model: "Destroyer",
                    plastic: "Star",
                    thumbImageID: "usedItem\(i)",
                    price: 25,
                    location: Location(latitude: 222, longitude: 333),
                    itemType: .disc,
                    images: {
                        ["usedItem\(i)"].map { MarketImage(uid: $0, image: UIImage(named: $0) ?? UIImage())}
                    }()
                )
            )
        }
        
        return arr
    }
    
    static var items: [MarketItemV2] {
        usedItems + goodItems + usedItems + usedItems
    }
    
    static let goodItems: [MarketItemV2] = [
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Discraft Raptor",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "Raptor2",
            price: 15,
            location: Location(latitude: 29, longitude: -81),
            itemType: .disc,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            seller: AppUser.users[0],
            imageIDs: ["Raptor1"]
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "Trespass2",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag,
            seller: AppUser.users[2],
            imageIDs: ["Trespass1", "logo2"],
            images: {
                ["Trespass2","Trespass1","logo2"].map { MarketImage(uid: $0, image: UIImage(named: $0) ?? UIImage())}
            }()
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Star Destroyer",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "colorDiscs",
            price: 15,
            location: Location(latitude: 123, longitude: 245),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Star Destroyer",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "colorDiscs",
            price: 15,
            location: Location(latitude: 123, longitude: 245),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Star Destroyer",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "colorDiscs",
            price: 15,
            location: Location(latitude: 123, longitude: 245),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Star Destroyer",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "colorDiscs",
            price: 15,
            location: Location(latitude: 123, longitude: 245),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Star Destroyer",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "colorDiscs",
            price: 15,
            location: Location(latitude: 123, longitude: 245),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Ricky Wysocki Robot Star Destroyer - brand new",
            manufacturer: "Innova",
            model: "Destroyer",
            plastic: "Star",
            thumbImageID: "logo2",
            price: 25,
            location: Location(latitude: 222, longitude: 333),
            itemType: .disc
        ),
        
        MarketItemV2(
            id: UUID().uuidString,
            headline: "Brand New DD Trooper",
            manufacturer: "Dynamic Discs",
            model: "Trooper",
            plastic: "N/A",
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        )
    ]
}

// MARK: - Equatable

extension MarketItemV2: Equatable {
    static func == (lhs: MarketItemV2, rhs: MarketItemV2) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension MarketItemV2: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

