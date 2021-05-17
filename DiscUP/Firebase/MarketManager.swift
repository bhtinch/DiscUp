//
//  MarketManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class MarketManager {
    static let database = MarketDB.shared.dbRef
    static let userID = Auth.auth().currentUser?.uid
    static let userDatabase = UserDB.shared.dbRef
        
    static func update(item: MarketItem, uploadImages: [UIImage], deletedImageIDs: [String], completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(NetworkError.noUser)) }
        
        let imageIDsString = item.imageIDs.joined(separator: ",")
        
        database.child(item.id).updateChildValues([
            
            MarketKeys.owner : userID,
            MarketKeys.headline : item.headline,
            MarketKeys.manufacturer : item.manufacturer,
            MarketKeys.model : item.model,
            MarketKeys.plastic : item.plastic ?? "null",
            MarketKeys.weight : item.weight ?? 000,
            MarketKeys.description : item.description,
            MarketKeys.imageIDs : imageIDsString,
            MarketKeys.thumbImageID : item.thumbImageID
            
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
            let weight = itemSnap.childSnapshot(forPath: MarketKeys.weight).value as? Double ?? 000
            let imageIDsString = itemSnap.childSnapshot(forPath: MarketKeys.imageIDs).value as? String ?? ""
            let thumbImageID = itemSnap.childSnapshot(forPath: MarketKeys.thumbImageID).value as? String ?? ""
            
            let imageIDs = imageIDsString.components(separatedBy: ",")
            
            let item = MarketItem(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description, imageIDs: imageIDs, thumbImageID: thumbImageID)
            
            completion(item)
        }
    }
    
    static func queryOffers() {
        
    }  //   NEEDS IMPLEMENTATION
    
}   //  End of Class
