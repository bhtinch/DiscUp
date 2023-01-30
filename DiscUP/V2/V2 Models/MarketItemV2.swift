//
//  MarketItemV2.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit

// MARK: - MarketItemEditableValue

enum MarketItemV2EditableValue {
    case headline, manufacturer, model, plastic, thumbImageID, price, location, itemType, description, imageIDs
}

// MARK: - MarketItemV2

class MarketItemV2: ObservableObject {
    
    //  MARK: - Properties
    
    let id: String
    
    var headline: String
    var manufacturer: String
    var model: String
    var plastic: String
    var weight: Double
    var thumbImageID: String
    var price: Int
    var location: Location
    var itemType: MarketItemV2Type
    var description: String
    var seller: AppUser
    var imageIDs: [String]
    
    @Published var images: [MarketImage]
    
    //  MARK: - Initialization
    
    init(
        id: String,
        headline: String,
        manufacturer: String,
        model: String,
        plastic: String,
        weight: Double,
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
    
    convenience init?(marketItem: MarketItem, type: MarketItemV2Type) {
        guard
            let ownerID = marketItem.ownerID,
            let price = marketItem.askingPrice
        else { return nil }
        
        self.init(
            id: marketItem.id,
            headline: marketItem.headline,
            manufacturer: marketItem.manufacturer,
            model: marketItem.model,
            plastic: marketItem.plastic ?? "",
            weight: marketItem.weight ?? 0,
            thumbImageID: marketItem.thumbImageID,
            price: price,
            location: marketItem.sellingLocation,
            itemType: type,
            description: marketItem.description,
            seller: AppUser(userID: ownerID),
            imageIDs: marketItem.imageIDs
        )
    }
    
    convenience init?(marketItemBasic: MarketItemBasic, type: MarketItemV2Type) {
        self.init(
            id: marketItemBasic.id,
            headline: marketItemBasic.headline,
            manufacturer: marketItemBasic.manufacturer,
            model: marketItemBasic.model,
            plastic: marketItemBasic.plastic ?? "",
            weight: 0,
            thumbImageID: marketItemBasic.thumbImageID,
            price: 0,
            location: Location.unknownLocation,
            itemType: type,
            description: "No description",
            seller: AppUser.unknownUser
        )
    }
    
    //  MARK: - DefaultNoItem
    
    static var defaultNoItem: MarketItemV2 = MarketItemV2(
        id: UUID().uuidString,
        headline: "No Item Selected",
        manufacturer: "N/A",
        model: "N/A",
        plastic: "N/A",
        weight: 0,
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
                    weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 0,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 0,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 175,
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
            weight: 0,
            thumbImageID: "pdgaLogo",
            price: 20,
            location: Location(latitude: 111, longitude: 222),
            itemType: .bag
        )
    ]
}

//  MARK: - Internal Methods

extension MarketItemV2 {
    func fetchThumbImage() {
        self.fetchImages(imageIDs: [thumbImageID])
    }
    
    func fetchAdditionalImages() {
        self.fetchImages(imageIDs: self.imageIDs)
    }
}

//  MARK: - Private Methods

extension MarketItemV2 {
    private func fetchImages(imageIDs: [String]) {
        for id in imageIDs {
            fetchImageWith(imageID: id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let image):
                    let marketImage = MarketImage(uid: id, image: image, isThumbImage: id == self.thumbImageID)
                    
                    self.images.append(marketImage)
                    
                case .failure(let error):
                    //  MARK: - BenDo: handle error?
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchImageWith(imageID: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        StorageManager.downloadURLFor(imageID: imageID) { result in
            switch result {
            case .success(let url):
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return completion(.failure(NetworkError.databaseError)) }
                    
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    }
                }
                task.resume()
                
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
        }
    }
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
    
