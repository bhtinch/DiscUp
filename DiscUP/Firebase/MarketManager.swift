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
        
        database.child(item.id).setValue([
            
            MarketKeys.owner : userID,
            MarketKeys.headline : item.headline,
            MarketKeys.manufacturer : item.manufacturer,
            MarketKeys.model : item.model,
            MarketKeys.plastic : item.plastic ?? "null",
            MarketKeys.weight : item.weight ?? 000,
            MarketKeys.description : item.description
            
        ]) { error, dbRef in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
            
            updateUserWith(userID: userID, item: item) { result in
                switch result {
                case .success(_):
                    return completion(.success(true))
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
    
    static func fetchMyOffers() {
        
    }  //   NEEDS IMPLEMENTATION
    
    static func queryOffers() {
        
    }  //   NEEDS IMPLEMENTATION
    
}   //  End of Class
