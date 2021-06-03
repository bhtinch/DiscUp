//
//  AuthManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import FirebaseAuth
import Foundation
import FirebaseDatabase
import FirebaseStorage

class AuthManager {
    
    /// Attempt to register a new user with Firebase Authentication
    static func registerNewUserWith(email: String, password: String, username: String, firstName: String?, lastName: String?, completion: @escaping (Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            guard error == nil,
                  let userID = authResult?.user.uid else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges()
            
            UserDB.shared.insertNewUserWith(userID: userID, email: email, username: username, firstName: firstName, lastName: lastName) { (test) in
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
    
    /// Attempt to reauthenticate firebase user
    static func reauthenticateUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Auth.auth().currentUser?.reauthenticate(with: credential) { (_, error) in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    return completion(false)
                }
            } else {
                print("User successfully reauthenticated...")
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
    /// Attempt to send password reset email through Firebase Auth
    static func sendUserPasswordResetEmail(completion: @escaping (Bool) -> Void) {
        let email = Auth.auth().currentUser?.email ?? "no user"
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                completion(false)
            }
        }
        
        DispatchQueue.main.async {
            return completion(true)
        }
    }
    
    static func deleteUser(completion: @escaping (Bool) -> Void){
        guard let user = Auth.auth().currentUser else { return completion(false) }
        
        let userID = user.uid
        
        UserDB.shared.dbRef.child(userID).child(UserKeys.offers).observeSingleEvent(of: .value) { snap in
            if snap.exists() {
                if let dict = snap.value as? NSDictionary {
                
                    let keyEnumerator = dict.keyEnumerator()
                
                    for key in keyEnumerator {
                        if let itemID = key as? String {
                            MarketManager.deleteOfferWith(itemID: itemID)
                        }
                    }
                }
            }
            completion(false)
        }
        
//        StorageManager.storage.child(userID).delete()
//        UserDB.shared.dbRef.child(userID).removeValue()
//
//        user.delete { error in
//            if let error = error {
//                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
//                return completion(false)
//            }
//
//            print("user account with id: \(user.uid) successfully deleted")
//            completion(true)
//        }
    }
    
    /// Presents an alert controller to inform user of action taken with phrase specified.  'OK' is the only action and dismisses the alert.
    static func presentActionUpdateAlert(with phrase: String, sender: UIViewController) {
        let alert = UIAlertController(title: phrase, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        sender.present(alert, animated: true, completion: nil)
    }
}   //  End of Class

