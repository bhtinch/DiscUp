//
//  BagManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import Foundation
import FirebaseDatabase

struct BagKeys {
    static let discIDs = "discs"
    static let name = "name"
    static let brand = "brand"
    static let model = "model"
    static let color = "color"
    static let isDefault = "isDefault"
}

class BagManager {
    
    static let database = UserDB.shared.dbRef
    
    static func getDefaultBag(completion: @escaping (Result<Bag, NetworkError>) -> Void) {
        let pathString = "\(UserKeys.userID)/\(UserKeys.bags)"
        
        database.child(pathString).observeSingleEvent(of: .value) { (snapshot) in
            
            var bagID = ""
            
            if snapshot.hasChildren() == false {
                DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
                return
            }
            
            for child in snapshot.children.allObjects {
                guard let childSnap = child as? DataSnapshot,
                      let test = childSnap.childSnapshot(forPath: BagKeys.isDefault).value as? Bool else {
                    DispatchQueue.main.async { completion(.failure(NetworkError.databaseError)) }
                    return
                }
                if test {
                    bagID = childSnap.key
                }
            }
            
            database.child(pathString).queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snap) in
                for child in snap.children {
                    guard let childSnap = child as? DataSnapshot else {
                        DispatchQueue.main.async { completion(.failure(NetworkError.databaseError)) }
                        return
                    }
                    bagID = childSnap.key as String
                }
            }
            
            database.child(pathString).child(bagID).observeSingleEvent(of: .value) { (snap) in
                for child in snap.children  {
                    guard let childSnap = child as? DataSnapshot else {
                        DispatchQueue.main.async { completion(.failure(NetworkError.databaseError)) }
                        return
                    }
                    
                    let name = childSnap.childSnapshot(forPath: BagKeys.name).value as? String ?? ""
                    let brand = childSnap.childSnapshot(forPath: BagKeys.brand).value as? String ?? ""
                    let model = childSnap.childSnapshot(forPath: BagKeys.model).value as? String ?? ""
                    let color = childSnap.childSnapshot(forPath: BagKeys.color).value as? String ?? ""
                    let isDefault = childSnap.childSnapshot(forPath: BagKeys.isDefault).value as? Bool ?? false
                    let NSdiscIDs = childSnap.childSnapshot(forPath: BagKeys.discIDs).value as? NSDictionary
                    
                    let discIDs = NSdiscIDs as? Dictionary<String, String> ?? Dictionary()
                    
                    let bag = Bag(name: name, brand: brand, model: model, color: color, discIDs: discIDs, isDefault: isDefault, uuidString: bagID)
                    
                    DispatchQueue.main.async { return completion(.success(bag)) }
                }
            }
        }
    }
    
    static func getBagWith(bagID: String, completion: @escaping (Result<Bag, NetworkError>) -> Void) {
        print("fetching bag with ID: \(bagID)...")
        
        let pathString = "\(UserKeys.userID)/\(UserKeys.bags)/\(bagID)"
        
        database.child(pathString).observeSingleEvent(of: .value) { (snap) in
            if snap.exists() == false {
                DispatchQueue.main.async {
                    return completion(.failure(NetworkError.noData))
                }
            } else {
                let bagID = snap.key as String
                let name = snap.childSnapshot(forPath: BagKeys.name).value as? String ?? ""
                let brand = snap.childSnapshot(forPath: BagKeys.brand).value as? String ?? ""
                let model = snap.childSnapshot(forPath: BagKeys.model).value as? String ?? ""
                let color = snap.childSnapshot(forPath: BagKeys.color).value as? String ?? ""
                let isDefault = snap.childSnapshot(forPath: BagKeys.isDefault).value as? Bool ?? false
                let NSdiscIDs = snap.childSnapshot(forPath: BagKeys.discIDs).value as? NSDictionary
                
                let discIDs = NSdiscIDs as? Dictionary<String, String> ?? Dictionary()
                
                let bag = Bag(name: name, brand: brand, model: model, color: color, discIDs: discIDs, isDefault: isDefault, uuidString: bagID)
                
                DispatchQueue.main.async {
                    return completion(.success(bag))
                }
            }
        }
    }
    
    static func createNewBagWith(name: String, brand: String, model: String, color: String, isDefault: Bool) {
        let pathString = "\(UserKeys.userID)/\(UserKeys.bags)"
        
        database.child(pathString).childByAutoId().setValue([
            BagKeys.name : name,
            BagKeys.brand : brand,
            BagKeys.model : model,
            BagKeys.color : color,
            BagKeys.isDefault : isDefault,
            BagKeys.discIDs : [String]()
        ]) { (error, dbRef) in
            if let _ = error {
                DispatchQueue.main.async {
                    print("Could not create new bag.")
                }
            } else {
                DispatchQueue.main.async {
                    dbRef.observeSingleEvent(of: .value) { (snap) in
                        print(snap.key)
                    }
                }
            }
        }
    }
    
    static func addDiscWith(discID: String, discModel: String, toBagWith bagID: String) {
        let pathString = "\(UserKeys.userID)/\(UserKeys.bags)/\(bagID)/\(BagKeys.discIDs)"
        database.child(pathString).updateChildValues([discID : discModel])
    }
    
    static func removeDiscWith(discID: String, fromBagWith bagID: String) {
        let path = "\(UserKeys.userID)/\(UserKeys.bags)/\(bagID)/\(BagKeys.discIDs)/\(discID)"
        database.child(path).removeValue()
    }
    
}   //  End of Class
