//
//  MarketManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Combine
import Foundation
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import GeoFire

class MarketManager {
    //  MARK: - V2 Properties
    static let marketDB = Firestore.firestore()
    static let locationManager = LocationManager.shared
    
    static let propertiesCollectionID = "propertiesCollection"
    
    //  MARK: - Legacy Properties
    static let database = MarketDB.shared.dbRef
    static let userID = Auth.auth().currentUser?.uid
    static let userDatabase = UserDB.shared.dbRef
    
    static let fetchedItemPublisher = PassthroughSubject<MarketItemV2, Never>()
    
    static var itemCache = ItemCache.shared
    
    static var cancellables = Set<AnyCancellable>()
    
    //  MARK: - V2 Methods
    static func add(item: MarketItemV2) async throws {
        let collectionRef = marketDB.collection("items")
        
        guard
            var itemDataModel = await MarketItemDataModel(item),
            let userID = userID
        else { return }
        
        // remove dummy id from new item, FB will create id
        if itemDataModel.id == "" {
            itemDataModel.id = nil
        }
        
        // create properties collection ref and add new document from data
        let docRef = try collectionRef.addDocument(from: itemDataModel)
        
        // update image ids with userID and itemID
        item.images.forEach {
            $0.id += ".\(docRef.documentID).\(userID)"
        }
        
        // Save images to storage syncronously
        StorageManager.upload(images: item.images) { error in
            //  MARK: - BenDo: Handle Error
            
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetch(docRef: DocumentReference, errorHandler: ((Error) -> Void)? = nil) {
        docRef.getDocument(as: MarketItemDataModel.self) { result in
            result.publisher
                .sink { completion in
                    switch completion {
                    case .finished:             break
                    case .failure(let error):   errorHandler?(error)
                    }
                } receiveValue: { itemDataModel in
                    guard
                        let item = MarketItemV2(itemDataModel)
                    else {
                        errorHandler?(DescriptiveError.couldNotCreateMarketItemModelFromDataModel)
                        return
                    }
                    
                    fetchedItemPublisher.send(item)
                    itemCache.insert(item)
                }
                .store(in: &cancellables)
        }
    }
        
    static func fetchItems(
        searchText: String? = nil,
        searchPostingDate: Date = Date(),
        searchLocation: Location = Location.userCurrentLocation ?? Location.defaultLocation,
        radiusMeters: Int,
        sellerID: String? = nil
    ) {
        let searchDateString = searchPostingDate.dateToString(format: .yearMonthDay)
        let searchCoordinate = searchLocation.coordinate
        let radiusMetersDouble = Double(radiusMeters)
        
        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: searchCoordinate, withRadius: radiusMetersDouble)
        
        let queries = queryBounds.map { bound -> Query in
            return marketDB.collection("items")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        queries.forEach { query in
            query.getDocuments { snapshot, error in
                guard var documents = snapshot?.documents else {
                    print("Unable to fetch snapshot data. \(String(describing: error))")
                    return
                }
                
                // TODO: Typesense filtering
                if let searchText = searchText {
                    documents.filter { _ in
                        true
                    }
                }
                
                for document in documents {
                    // check cache to see if item is already fetched
                    if let cachedItem = itemCache.getItem(with: document.documentID) {
                        fetchedItemPublisher.send(cachedItem)
                        continue
                    }
                    
                    let docData = document.data()
                    let lat = docData["lat"] as? Double ?? 0
                    let lng = docData["long"] as? Double ?? 0
                    let coordinates = CLLocation(latitude: lat, longitude: lng)
                    let centerPoint = CLLocation(latitude: searchLocation.latitude, longitude: searchLocation.longitude)
                    
                    // We have to filter out a few false positives due to GeoHash accuracy, but
                    // most will match
                    let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                    
                    guard
                        distance <= radiusMetersDouble
                    else { continue }
                    
                    fetch(docRef: document.reference)
                }
            }
        }
    }
    
    static func fetchAllItemsSoldByUser(sellerID: String) {
        let query = marketDB.collection("items").whereField("sellerID", isEqualTo: sellerID)
        
        query.getDocuments { snapshot, error in
            guard var documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            for document in documents {
                // check cache to see if item is already fetched
                if let cachedItem = itemCache.getItem(with: document.documentID) {
                    fetchedItemPublisher.send(cachedItem)
                    continue
                }
                
                fetch(docRef: document.reference)
            }
        }
    }
    
    
    //  MARK: - *************************** Legacy Methods ***********************
        
    static func update(item: MarketItem, uploadImages: [UIImage], deletedImageIDs: [String], completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(NetworkError.noUser)) }
        
        let locationArrayString = "\(item.sellingLocation.latitude),\(item.sellingLocation.longitude)"
        
        let imageIDsString = item.imageIDs.joined(separator: ",")
        
        let updatedTimestamp = item.updatedTimestamp.convertToUTCString(format: .fullNumericWithTimezone)
        
        database.child(MarketKeys.coordinates).child(item.id).updateChildValues([
            MarketKeys.latitude : item.sellingLocation.latitude,
            MarketKeys.longitude : item.sellingLocation.longitude
        ])
        
        database.child(item.id).updateChildValues([
            
            MarketKeys.owner : userID,
            MarketKeys.headline : item.headline,
            MarketKeys.manufacturer : item.manufacturer,
            MarketKeys.model : item.model,
            MarketKeys.plastic : item.plastic ?? "null",
            MarketKeys.weight : item.weight ?? 0,
            MarketKeys.description : item.description,
            MarketKeys.imageIDs : imageIDsString,
            MarketKeys.thumbImageID : item.thumbImageID,
            MarketKeys.askingPrice : item.askingPrice ?? 0,
            MarketKeys.sellingLocation : locationArrayString,
            MarketKeys.updatedTimestamp : updatedTimestamp,
            MarketKeys.inputZipCode : item.inputZipCode
            
        ]) { error, dbRef in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
            
            
            if !deletedImageIDs.isEmpty {
                StorageManager.deleteImagesWith(imageIDs: deletedImageIDs) { success in
                    if success {
                        print("Images successfully deleted from Firebase Storage.")
                    } else {
                        print("Error deleted images from Firebase Storage.")
                    }
                }
            }
                        
            updateUserWith(userID: userID, item: item) { result in
                switch result {
                case .success(_):
                    print("Successfully updated user info with new offer.")
                    
                    if uploadImages.isEmpty { return completion(.success(true)) }
                    
                    StorageManager.uploadImagesWith(images: uploadImages) { result in
                        switch result {
                        case .success(_):
                            
                            print("Successfully uploaded photos to Firebase Storage.")
                            return completion(.success(true))
                            
                        case .failure(let error):
                            print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                            return completion(.failure(NetworkError.failedToUploadToStorage))
                        }
                    }
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(.failure(NetworkError.databaseError))
                }
            }
        }
    }
    
    static func updateUserWith(userID: String, item: MarketItem, completion: @escaping(Result<Bool, NetworkError>) -> Void) {
        let pathString = "\(userID)/\(UserKeys.offers)"
        
        userDatabase.child(pathString).updateChildValues([
            item.id : "\(item.manufacturer) \(item.model)"
        ]) { error, _ in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
            
            return completion(.success(true))
        }
    }
    
    static func deleteOfferWith(itemID: String, completion: @escaping(Bool) -> Void) {
        
        database.child(itemID).child(MarketKeys.thumbImageID).observeSingleEvent(of: .value) { snap in
            if snap.exists() {
                if let id = snap.value as? String {
                    StorageManager.deleteImagesWith(imageIDs: [id]) { _ in
                        
                        database.child(itemID).child(MarketKeys.imageIDs).observeSingleEvent(of: .value) { snap in
                            if snap.exists() {
                                if let imageIDsString = snap.value as? String {
                                    let imageIDs = imageIDsString.components(separatedBy: ",")
                                    
                                    StorageManager.deleteImagesWith(imageIDs: imageIDs) { _ in
                                        database.child(itemID).removeValue()
                                        database.child(MarketKeys.coordinates).child(itemID).removeValue()
                                        userDatabase.child(UserKeys.offers).child(itemID).removeValue()
                                        
                                        completion(true)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                database.child(itemID).removeValue()
                database.child(MarketKeys.coordinates).child(itemID).removeValue()
                userDatabase.child(UserKeys.offers).child(itemID).removeValue()
                
                completion(true)
            }
        }
    }
    
    static func fetchMyOffers(completion: @escaping (Result<[MarketItemBasic], NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(NetworkError.noUser)) }
        
        let pathString = "\(userID)/\(UserKeys.offers)"
        var items: [MarketItemBasic] = []
        
        userDatabase.child(pathString).observeSingleEvent(of: .value) { snap in
            let itemCount = snap.children.allObjects.count
            var i = 0
            
            for child in snap.children {
                i += 1
                
                if let childSnap = child as? DataSnapshot {
                    let itemID = childSnap.key
                    
                    database.child(itemID).observeSingleEvent(of: .value) { itemSnap in
                        
                        let headline = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
                        let manufacturer = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
                        let model = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
                        let plastic = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
                        let thumbImageID = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
                        
                        let itemBasic = MarketItemBasic(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, thumbImageID: thumbImageID)
                        
                        items.append(itemBasic)
                        
                        if i == itemCount {
                            completion(.success(items))
                        }
                    }
                }
            }
        }
    }
    
    static func fetchMarketBasicItemWith(itemID: String, completion: @escaping(MarketItemBasic) -> Void) {
        database.child(itemID).observeSingleEvent(of: .value) { itemSnap in
            
            let headline        = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
            let manufacturer    = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
            let model           = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
            let plastic         = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
            let thumbImageID    = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
            
            let itemBasic = MarketItemBasic(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, thumbImageID: thumbImageID)
            
            completion(itemBasic)
        }
    }
    
    static func fetchImageWith(imageID: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
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
    
    static func fetchItemWith(itemID: String, completion: @escaping (MarketItem?) -> Void) {
        database.child(itemID).observeSingleEvent(of: .value) { itemSnap in
            completion(MarketItem(itemID: itemID, itemSnap: itemSnap))
        }
    }
    
    static func fetchItemWith(itemID: String) {
        database.child(itemID).observeSingleEvent(of: .value) { itemSnap in
            let marketItem = MarketItem(itemID: itemID, itemSnap: itemSnap)
            
            guard let marketItemV2 = MarketItemV2(marketItem: marketItem, type: .disc) else { return }
            
            fetchedItemPublisher.send(marketItemV2)
        }
    }
    
    //  MARK: - BenDo:  THIS ONE OBSOLETE NOW THAT THE PUBLISHER HAS BEEN ADDED???  This method needs help... need to add range and better querying of lat AND long.  search range save for V2.1
    /// returns an array of market item IDs for sale within a specified range (in miles) from the provided location
    static func fetchOfferIDsWithin(searchTerm: String? = nil, range: SearchRange, of location: Location, completion: @escaping(Result<[String], NetworkError>) -> Void) {
        
        var itemIDs: [String] = []
        
        let buyerLatitude = location.latitude
        let buyerLongitude = location.longitude
        
        database.child(MarketKeys.coordinates)
            .queryOrdered(byChild: MarketKeys.latitude)
            .queryStarting(atValue: buyerLatitude - range.latitudeDegrees , childKey: MarketKeys.latitude)
            .queryEnding(atValue: buyerLatitude + range.latitudeDegrees, childKey: MarketKeys.latitude)
            .observeSingleEvent(of: .value)
        { snap in
            var i = 0
            
            if snap.childrenCount == 0 { return completion(.success(itemIDs)) }
            
            for child in snap.children {
                i += 1
                
                if let childSnap = child as? DataSnapshot {
                    if let itemLongitude = childSnap.childSnapshot(forPath: MarketKeys.longitude).value as? Double {
                        
                        if
                            itemLongitude >= buyerLongitude - range.longitudeDegrees &&
                            itemLongitude <= buyerLongitude + range.longitudeDegrees
                        {
                            if let searchTerm = searchTerm {
                                let item = MarketItem(itemID: childSnap.key, itemSnap: childSnap)
                                
                                guard
                                    item.headline.localizedCaseInsensitiveContains(searchTerm) ||
                                        item.description.localizedCaseInsensitiveContains(searchTerm)
                                else { break }
                                
                                itemIDs.append(childSnap.key)
                                
                            } else {
                                itemIDs.append(childSnap.key)
                            }
                        }
                    }
                }
                
                if i == snap.childrenCount {
                    completion(.success(itemIDs))
                }
            }
        }
    }
    
    //  MARK: - BenDo: This method needs help... need to add range and better querying of lat AND long.  CURRENTLY NOT WORKING FOR KEYWORD SEARCH
    static func fetchOffers(searchTerm: String? = nil, within range: SearchRange, of location: Location) {
        
        let buyerLatitude = location.latitude
        let buyerLongitude = location.longitude
        
        database.child(MarketKeys.coordinates)
            .queryOrdered(byChild: MarketKeys.latitude)
            .queryStarting(atValue: buyerLatitude - range.latitudeDegrees , childKey: MarketKeys.latitude)
            .queryEnding(atValue: buyerLatitude + range.latitudeDegrees, childKey: MarketKeys.latitude)
            .observeSingleEvent(of: .value)
        { snap in
            
            if snap.childrenCount == 0 { return }
            
            for child in snap.children {
                
                if let childSnap = child as? DataSnapshot {
                    if let itemLongitude = childSnap.childSnapshot(forPath: MarketKeys.longitude).value as? Double {
                        
                        if
                            itemLongitude >= buyerLongitude - range.longitudeDegrees &&
                            itemLongitude <= buyerLongitude + range.longitudeDegrees
                        {
                            if let searchTerm = searchTerm {
                                let item = MarketItem(itemID: childSnap.key, itemSnap: childSnap)
                                
                                guard
                                    item.headline.localizedCaseInsensitiveContains(searchTerm) ||
                                        item.description.localizedCaseInsensitiveContains(searchTerm)
                                else { break }
                                
                                fetchItemWith(itemID: childSnap.key)
                                
                            } else {
                                fetchItemWith(itemID: childSnap.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
