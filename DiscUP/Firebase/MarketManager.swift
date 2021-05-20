//
//  MarketManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class MarketManager {
    static let database = MarketDB.shared.dbRef
    static let userID = Auth.auth().currentUser?.uid
    static let userDatabase = UserDB.shared.dbRef
        
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
    
    static func deleteOffer() {
        
    }  //   NEEDS IMPLEMENTATION
    
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
            
            let headline = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
            let manufacturer = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
            let model = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
            let plastic = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
            let thumbImageID = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
            
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
            
            let description = itemSnap.childSnapshot(forPath: MarketKeys.description).value as? String ?? "(description)"
            let headline = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
            let manufacturer = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
            let model = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
            let plastic = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
            var weight = itemSnap.childSnapshot(forPath: MarketKeys.weight).value as? Double
            let imageIDsString = itemSnap.childSnapshot(forPath: MarketKeys.imageIDs).value as? String ?? ""
            let thumbImageID = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
            var askingPrice = itemSnap.childSnapshot(forPath: MarketKeys.askingPrice).value as? Int
            let sellingLocation = itemSnap.childSnapshot(forPath: MarketKeys.sellingLocation).value as? String ?? "Unknown Location"
            let updatedTimestampString = itemSnap.childSnapshot(forPath: MarketKeys.updatedTimestamp).value as? String
            let inputZipCode = itemSnap.childSnapshot(forPath: MarketKeys.inputZipCode).value as? String
            let ownerID = itemSnap.childSnapshot(forPath: MarketKeys.owner).value as? String
            
            let imageIDs = imageIDsString.components(separatedBy: ",")
            
            if askingPrice == 0 { askingPrice = nil }
            if weight == 0 { weight = nil }
            
            let updatedTimestamp = updatedTimestampString?.stringToLocalDate(format: .fullNumericWithTimezone) ?? Date.distantPast
            
            let sellingLocationArray = sellingLocation.split(separator: ",")
            
            let location = Location(latitude: Double(sellingLocationArray[0]) ?? 0, longitude: Double(sellingLocationArray[1]) ?? 0)
            
            let item = MarketItem(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description, imageIDs: imageIDs, thumbImageID: thumbImageID, askingPrice: askingPrice, sellingLocation: location, updatedTimestamp: updatedTimestamp, inputZipCode: inputZipCode, ownerID: ownerID)
            
            completion(item)
        }
    }
    
    static func fetchOffersWithin(range: String, of location: Location, completion: @escaping(Result<[String], NetworkError>) -> Void) {
        
        var itemIDs: [String] = []
        
        let buyerLatitude = location.latitude
        let buyerLongitude = location.longitude
        
        database.child(MarketKeys.coordinates).queryOrdered(byChild: MarketKeys.latitude).queryStarting(atValue: buyerLatitude - 1 , childKey: MarketKeys.latitude).queryEnding(atValue: buyerLatitude + 1, childKey: MarketKeys.latitude).observeSingleEvent(of: .value) { snap in
            var i = 0
            
            for child in snap.children {
                i += 1
                if let childSnap = child as? DataSnapshot {
                    if let itemLongitude = childSnap.childSnapshot(forPath: MarketKeys.longitude).value as? Double {
                        if itemLongitude >= buyerLongitude - 1 && itemLongitude <= buyerLongitude + 1 {
                            itemIDs.append(childSnap.key)
                        }
                    }
                }
                
                if i == snap.childrenCount {
                    completion(.success(itemIDs))
                }
            }
        }
    }
    
}   //  End of Class
