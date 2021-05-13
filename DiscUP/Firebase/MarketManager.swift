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
    
    static func createNewOfferWith(item: MarketItem, completion: @escaping(Result<Bool, NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(NetworkError.noUser))}
        
        var imageIDs: [String] = []
        
        for image in item.images {
            imageIDs.append(image.accessibilityIdentifier ?? "\(item.id)_\(UUID().uuidString)")
        }
        
        let imageIDsString = imageIDs.joined(separator: ",")
        
        database.child(item.id).setValue([
            
            MarketKeys.owner : userID,
            MarketKeys.headline : item.headline,
            MarketKeys.manufacturer : item.manufacturer,
            MarketKeys.model : item.model,
            MarketKeys.plastic : item.plastic ?? "null",
            MarketKeys.weight : item.weight ?? 000,
            MarketKeys.description : item.description,
            MarketKeys.imageIDs : imageIDsString
            
        ]) { error, dbRef in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
            
            updateUserWith(userID: userID, item: item) { result in
                switch result {
                case .success(_):
                    print("Successfully updated user info with new offer.")
                    
                    StorageManager.uploadImagesWith(images: item.images) { result in
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
    
    static func fetchMyOffers(completion: @escaping (Result<[MarketItem], NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(NetworkError.noUser)) }
        
        let pathString = "\(userID)/\(UserKeys.offers)"
        var items: [MarketItem] = []
        
        userDatabase.child(pathString).observeSingleEvent(of: .value) { snap in
            let itemCount = snap.children.allObjects.count
            var i = 0
            
            for child in snap.children {
                i += 1
                
                if let childSnap = child as? DataSnapshot {
                    let itemID = childSnap.key
                    
                    database.child(itemID).observeSingleEvent(of: .value) { itemSnap in
                        
                        let description = itemSnap.childSnapshot(forPath: MarketKeys.description).value as? String ?? "(description)"
                        let headline = itemSnap.childSnapshot(forPath: MarketKeys.headline).value as? String ?? "(headline)"
                        let manufacturer = itemSnap.childSnapshot(forPath: MarketKeys.manufacturer).value as? String ?? "manufacturer unknown"
                        let model = itemSnap.childSnapshot(forPath: MarketKeys.model).value as? String ?? "model unknown"
                        let plastic = itemSnap.childSnapshot(forPath: MarketKeys.plastic).value as? String ?? "plastic unknown"
                        let weight = itemSnap.childSnapshot(forPath: MarketKeys.weight).value as? Double ?? 000
                        let imageIDsString = itemSnap.childSnapshot(forPath: MarketKeys.imageIDs).value as? String ?? ""
                        
                        let imageIDs = imageIDsString.components(separatedBy: ",")
                        var images: [UIImage] = []
                        
                        for id in imageIDs {
                            
                            StorageManager.downloadURLFor(imageID: id) { result in
                                switch result {
                                case .success(let url):
                                    
                                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                        guard let data = data, error == nil else { return completion(.failure(NetworkError.databaseError)) }
                                        
                                        if let image = UIImage(data: data) {
                                            images.append(image)
                                            
                                            if id == imageIDs.last {
                                                let item = MarketItem(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description, images: images)
                                                
                                                items.append(item)
                                                
                                                if i == itemCount {
                                                    completion(.success(items))
                                                }
                                            }
                                        }
                                    }
                                    task.resume()
                                    
                                case .failure(let error):
                                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func queryOffers() {
        
    }  //   NEEDS IMPLEMENTATION
    
}   //  End of Class
