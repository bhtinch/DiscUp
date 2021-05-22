//
//  MessagingManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

enum ConversationType: String {
    case buyingMessages = "buyingMessages"
    case sellingMessages = "sellingMessages"
}

class MessagingManager {
    static let database = MessagingDB.shared.dbRef
    static let userDatabase = UserDB.shared.dbRef
    static let userID = Auth.auth().currentUser?.uid
    
    static func createNewConversationWith(item: MarketItem, text: String, completion: @escaping(String) -> Void) {
        guard let buyerID = userID,
              let sellerID = item.ownerID else { return completion("noConvoID") }
        
        //  create convoID
        database.childByAutoId().setValue([
            ConversationKeys.itemID : item.id,
            ConversationKeys.itemHeadline : item.headline,
            ConversationKeys.thumbImageID : item.thumbImageID,
            ConversationKeys.createdDate : Date().convertToUTCString(format: .fullNumericWithTimezone),
            ConversationKeys.sellerID : sellerID,
            ConversationKeys.buyerID : buyerID
        ]) { error, ref in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion("noConvoID")
            }
            
            guard let convoID = ref.key else {
                print("no ref key")
                return completion("noConvoID")
            }
            
            //  add convoID ref to buyer's 'buyingMessages'
            userDatabase.child("\(buyerID)/\(UserKeys.buyingMessages)").updateChildValues([
                item.id : [
                    UserKeys.conversationID : convoID,
                    UserKeys.messageCount : 0
                ]
            ])
            
            //  add convoID ref to seller's 'sellingMessages'
            userDatabase.child("\(sellerID)/\(UserKeys.sellingMessages)").updateChildValues([
                item.id : [
                    UserKeys.conversationID : convoID,
                    UserKeys.messageCount : 0
                ]
            ])
            
            //  send first message
            DispatchQueue.main.async {
                sendMessage(to: convoID, with: text) { success in
                    if success == false {
                        return completion("noConvoID")
                    }
                    completion(convoID)
                }
            }
        }
    }
    
    static func deleteConversation() {
        
    }  //   NEEDS IMPLEMENTATION
    
    static func sendMessage(to convID: String, with text: String, completion: @escaping(Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(false) }
        
        let sentDate = Date().convertToUTCString(format: .MM_dd_yyyy_T_HH_mm_ss_SSS_Z)
        
        database.child(convID).child(ConversationKeys.messages).child(sentDate).updateChildValues([
            MessageKeys.text : text,
            MessageKeys.senderID : user.uid,
            MessageKeys.senderDisplayName : user.displayName ?? "Unknown User"
        ]) {error, dbRef in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(false)
                }
                
                database.child(convID).observeSingleEvent(of: .value) { snap in
                    if let sellerID = snap.childSnapshot(forPath: ConversationKeys.sellerID).value as? String,
                       let buyerID = snap.childSnapshot(forPath: ConversationKeys.buyerID).value as? String,
                       let itemID = snap.childSnapshot(forPath: ConversationKeys.itemID).value as? String {
                        
                        let messageCount = snap.childSnapshot(forPath: ConversationKeys.messages).childrenCount
                        
                        var updateUserID: String = sellerID
                        var conversationType: ConversationType = .sellingMessages
                        
                        if buyerID == user.uid {
                            conversationType = .buyingMessages
                            updateUserID = buyerID
                        }
                        
                        userDatabase.child("\(updateUserID)/\(conversationType.rawValue)/\(itemID)").updateChildValues([UserKeys.messageCount : messageCount])
                        completion(true)
                    }
                }
            }
        }
    }
    
    static func fetchUserConvosWith(conversationType: ConversationType, completion: @escaping(Result<[String : Int], NetworkError>) -> Void) {
        guard let userID = userID else { return completion(.failure(.noUser)) }
        
        let pathString = "\(userID)/\(conversationType.rawValue)"
        
        userDatabase.child(pathString).observeSingleEvent(of: .value) { snap in
            
            guard snap.exists() else { return completion(.failure(NetworkError.noData)) }
            let childrenCount = Int(snap.childrenCount)
            
            var convoIDs: [String : Int] = [:]
            
            var i = 0
            
            for child in snap.children {
                i += 1
                if let childSnap = child as? DataSnapshot {
                    guard let convoID = childSnap.childSnapshot(forPath: UserKeys.conversationID).value as? String,
                          let userMessageCount = childSnap.childSnapshot(forPath: UserKeys.messageCount).value as? Int else { return completion(.failure(NetworkError.databaseError)) }
                    
                    convoIDs[convoID] = userMessageCount
                    
                    if i == childrenCount {
                        completion(.success(convoIDs))
                    }
                }
            }
        }
    }
    
    static func getConvoBasicWith(convoID: String, userMessageCount: Int, completion: @escaping(ConversationBasic?) -> Void) {
        
        database.child(convoID).observe(.value) { snap in
            let id = snap.key
            let messageCount = snap.childSnapshot(forPath: ConversationKeys.messages).childrenCount
            
            let newMessages = Int(messageCount) - userMessageCount
            
            guard let sellerID = snap.childSnapshot(forPath: ConversationKeys.sellerID).value as? String,
                  let buyerID = snap.childSnapshot(forPath: ConversationKeys.buyerID).value as? String,
                  let itemHeadline = snap.childSnapshot(forPath: ConversationKeys.itemHeadline).value as? String,
                  let itemID = snap.childSnapshot(forPath: ConversationKeys.itemID).value as? String,
                  let thumbImageID = snap.childSnapshot(forPath: ConversationKeys.thumbImageID).value as? String else { return completion(nil) }
            
            completion(ConversationBasic(id: id, newMessages: newMessages, sellerID: sellerID, buyerID: buyerID, itemID: itemID, itemHeadline: itemHeadline, thumbImageID: thumbImageID))
        }
    }
    
}   //  End of Class




