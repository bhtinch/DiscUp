//
//  AuthManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import FirebaseAuth
import Foundation

class AuthManager {
    
    /// Attempt to register a new user with Firebase Authentication
    static func registerNewUserWith(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            guard error == nil,
                  let userID = authResult?.user.uid else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            UserDB.shared.insertNewUserWith(userID: userID, email: email) { (test) in
                if test {
                    print("New Firebase User added to the user database.")
                    DispatchQueue.main.async {
                        return completion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        return completion(false)
                    }
                }
            }
        }
    }
    
    /// Attempt to login firebase user
    static func loginUserWith(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard error == nil, authResult != nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                return completion(true)
            }
        }
    }
    
    /// Attempt to logout firebase user
    static func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("firebase user logged out")
        } catch {
            print("Could not sign out.")
        }
    }
    
    static func deleteUser(){
        //  NEEDS IMPLEMENTATION
    }
}   //  End of Class

