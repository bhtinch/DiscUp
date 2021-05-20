//
//  UserDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import FirebaseAuth
import FirebaseDatabase
import Foundation

struct UserKeys {
    //  User Object
    static let dateJoined = "Date Joined"
    static let bags = "Bags"
    static let racks = "Racks"
    static let email = "Email"
    static let userID = Auth.auth().currentUser?.uid ?? "No User"
    static let offers = "offers"
    static let conversations = "conversations"
    static let username = "username"
    static let firstName = "firstName"
    static let lastName = "lastName"
}

class UserDB {
    static let shared = UserDB()
    let database = Database.database(url: "https://discup-users-rtdb.firebaseio.com/")
    let dbRef = Database.database(url: "https://discup-users-rtdb.firebaseio.com/").reference()
    
    //  MARK: - Methods
    
    /// checks if user email already exists and, if not, creates new user object in firebase User database
    func insertNewUserWith(userID: String, email: String, username: String, firstName: String?, lastName: String?, completion: @escaping (Bool) -> Void) {
        //  if user already exists, return
        
        dbRef.child(userID).setValue([
            UserKeys.email : email,
            UserKeys.dateJoined : "\(Date())",
            UserKeys.username : username,
            UserKeys.firstName : firstName,
            UserKeys.lastName : lastName
        ])
                
        completion(true)
    }
    
    /// Attempts to remove the user object from the firebase User database
    func deleteUserWith() {}    //  NEEDS IMPLEMENTATION
    
    /// Attempts to update the child data of the user object in the firebase User database; currently valid only for single level top level children
    func updateUserWith(key: String, value: Any) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        dbRef.child(userID).updateChildValues([key : value])
    }
    
    func fetchUserInfoFor(userID: String, completion: @escaping(Result<UserProfile, NetworkError>) -> Void) {
        
        dbRef.child(userID).observeSingleEvent(of: .value) { snap in
            let username = snap.childSnapshot(forPath: UserKeys.username).value as? String
            let firstName = snap.childSnapshot(forPath: UserKeys.firstName).value as? String
            let lastName = snap.childSnapshot(forPath: UserKeys.lastName).value as? String
            
            guard let username = username else { return completion(.failure(NetworkError.noUser)) }
            
            let userProfile = UserProfile(id: userID, username: username, firstName: firstName, lastName: lastName)
            
            completion(.success(userProfile))
        }
    }

}
