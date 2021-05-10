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
}

class UserDB {
    static let shared = UserDB()
    let database = Database.database(url: "https://discup-users-rtdb.firebaseio.com/")
    let dbRef = Database.database(url: "https://discup-users-rtdb.firebaseio.com/").reference()
    
    //  MARK: - Methods
    
    /// checks if user email already exists and, if not, creates new user object in firebase User database
    func insertNewUserWith(userID: String, email: String, completion: @escaping (Bool) -> Void) {
        //  if user already exists, return
        
        dbRef.child(userID).setValue([
            UserKeys.email : email,
            UserKeys.dateJoined : "\(Date())",
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

}
