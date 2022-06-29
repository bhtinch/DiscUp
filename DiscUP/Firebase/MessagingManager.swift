//
//  MessagingManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase
import MessageKit

enum ConversationType: String {
    case buyingMessages = "buyingMessages"
    case sellingMessages = "sellingMessages"
}

class MessagingManager {
    static let database = MessagingDB.shared.dbRef
    static let userDatabase = UserDB.shared.dbRef
    static let userID = Auth.auth().currentUser?.uid
    
    static func createNewConversationWith(item: MarketItem, text: String?, imageID: String?, completion: @escaping(Result<ConversationBasic, NetworkError>) -> Void) {
        guard let buyerID = userID,
              let sellerID = item.ownerID else { return completion(.failure(NetworkError.databaseError)) }
        
        
        let createdDate = Date().convertToUTCString(format: .fullNumericWithTimezone)
        
        //  create convoID
        database.childByAutoId().setValue([
            ConversationKeys.itemID : item.id,
            ConversationKeys.itemHeadline : item.headline,
            ConversationKeys.thumbImageID : item.thumbImageID,
            ConversationKeys.createdDate : createdDate,
            ConversationKeys.sellerID : sellerID,
            ConversationKeys.buyerID : buyerID
        ]) { error, ref in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.databaseError))
            }
            
            guard let convoID = ref.key else {
                print("no ref key")
                return completion(.failure(NetworkError.databaseError))
            }
            
            let basicConvo = ConversationBasic(id: convoID, newMessages: 1, sellerID: sellerID, buyerID: buyerID, itemID: item.id, itemHeadline: item.headline, thumbImageID: item.thumbImageID)
            
            //  add convoID ref to buyer's 'buyingMessages'
            userDatabase.child("\(buyerID)/\(UserKeys.buyingMessages)").updateChildValues([
                item.id : [
                    UserKeys.conversationID : convoID,
                    UserKeys.messageCount : 0
                ]
            ])
            
            //  add convoID ref to seller's 'sellingMessages'
            userDatabase.child("\(sellerID)/\(UserKeys.sellingMessages)").updateChildValues([
                convoID : [
                    UserKeys.itemID : item.id,
                    UserKeys.messageCount : 0
                ]
            ])
            
            //  send first message
            DispatchQueue.main.async {
                sendMessage(to: convoID, with: text, imageID: imageID) { success in
                    if success == false {
                        return completion(.failure(NetworkError.databaseError))
                    }
                    completion(.success(basicConvo))
                }
            }
        }
    }
    
    static func deleteConversation() {
        
    }  //   NEEDS IMPLEMENTATION
    
    static func sendMessage(to convoID: String, with text: String?, imageID: String?, completion: @escaping(Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(false) }
        
        let sentDate = Date().convertToUTCString(format: .MM_dd_yyyy_T_HH_mm_ss_SSS_Z)
        
        database.child(convoID).child(ConversationKeys.messages).child(sentDate).updateChildValues([
            MessageKeys.text : text,
            MessageKeys.senderID : user.uid,
            MessageKeys.senderDisplayName : user.displayName ?? "Unknown User",
            MessageKeys.imageID : imageID
        ]) {error, dbRef in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(false)
                }
                
                resetMessageCount(convoID: convoID)
                return completion(true)
            }
        }
    }
    
    static func resetMessageCount(convoID: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        database.child(convoID).observeSingleEvent(of: .value) { snap in
            if let sellerID = snap.childSnapshot(forPath: ConversationKeys.sellerID).value as? String,
               let buyerID = snap.childSnapshot(forPath: ConversationKeys.buyerID).value as? String,
               let itemID = snap.childSnapshot(forPath: ConversationKeys.itemID).value as? String {
                
                let messageCount = snap.childSnapshot(forPath: ConversationKeys.messages).childrenCount
                
                var updateUserID: String = sellerID
                var conversationType: ConversationType = .sellingMessages
                var identifier: String = convoID
                
                if buyerID == user.uid {
                    conversationType = .buyingMessages
                    updateUserID = buyerID
                    identifier = itemID
                }
                
                userDatabase.child("\(updateUserID)/\(conversationType.rawValue)/\(identifier)").updateChildValues([UserKeys.messageCount : messageCount])
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
                    guard let userMessageCount = childSnap.childSnapshot(forPath: UserKeys.messageCount).value as? Int else { return completion(.failure(NetworkError.databaseError)) }
                    
                    var convoID = childSnap.childSnapshot(forPath: UserKeys.conversationID).value as? String
                    
                    if conversationType.rawValue == ConversationType.sellingMessages.rawValue {
                        convoID = childSnap.key
                    }
                    
                    guard let convoID = convoID else { return completion(.failure(NetworkError.databaseError)) }
                    
                    convoIDs[convoID] = userMessageCount
                    
                    if i == childrenCount {
                        completion(.success(convoIDs))
                    }
                }
            }
        }
    }
    
    static func getConvoBasicWith(convoID: String, userMessageCount: Int?, completion: @escaping(ConversationBasic?) -> Void) {
        
        database.child(convoID).observeSingleEvent(of: .value) { snap in
            let id = snap.key
            let messageCount = snap.childSnapshot(forPath: ConversationKeys.messages).childrenCount
            
            var newMessages = 0
            
            if userMessageCount != nil {
                newMessages = Int(messageCount) - userMessageCount!
            }
                        
            guard let sellerID = snap.childSnapshot(forPath: ConversationKeys.sellerID).value as? String,
                  let buyerID = snap.childSnapshot(forPath: ConversationKeys.buyerID).value as? String,
                  let itemHeadline = snap.childSnapshot(forPath: ConversationKeys.itemHeadline).value as? String,
                  let itemID = snap.childSnapshot(forPath: ConversationKeys.itemID).value as? String,
                  let thumbImageID = snap.childSnapshot(forPath: ConversationKeys.thumbImageID).value as? String else { return completion(nil) }
            
            completion(ConversationBasic(id: id, newMessages: newMessages, sellerID: sellerID, buyerID: buyerID, itemID: itemID, itemHeadline: itemHeadline, thumbImageID: thumbImageID))
        }
    }
    
    static func blockUserFromConversationWith(convoID: String, blockedUsersList: [String], completion: @escaping(Bool) -> Void) {
        guard let currentUserID = userID else { return completion(false) }
        
        database.child(convoID).observeSingleEvent(of: .value) { snap in
            guard let sellerID = snap.childSnapshot(forPath: ConversationKeys.sellerID).value as? String,
                  let buyerID = snap.childSnapshot(forPath: ConversationKeys.buyerID).value as? String else { return completion(false) }
            
            var blockUserID = sellerID
            
            if blockUserID == currentUserID {
                blockUserID = buyerID
            }
            
            var newBlockedList = blockedUsersList
            
            newBlockedList.append(blockUserID)
            
            let blockedString = newBlockedList.joined(separator: ",")
            
            userDatabase.child(currentUserID).updateChildValues([UserKeys.blockedUserIDs : blockedString])
            
            completion(true)
        }
    }
    
    static func fetchBlockedUsers(completion: @escaping([String]) -> Void) {
        guard let userID = userID else { return completion([]) }
        
        userDatabase.child(userID).child(UserKeys.blockedUserIDs).observeSingleEvent(of: .value) { snap in
            if !snap.exists() { return completion([]) }
            
            if let blockedString = snap.value as? String {
                
                let blockedArray = blockedString.components(separatedBy: ",")
                return completion(blockedArray)
            }
            
            completion([])
        }
    }
    
    static func unblockUserWith(id: String, blockedUserIDs: [String], completion: @escaping(Bool) -> Void) {
        guard let userID = userID,
              let index = blockedUserIDs.firstIndex(of: id) else { return completion(false) }
        
        var newBlockedList = blockedUserIDs
        
        newBlockedList.remove(at: index)
        
        let blockedString = newBlockedList.joined(separator: ",")
        
        if blockedString.count == 0 || blockedString == ""  {
            userDatabase.child(userID).child(UserKeys.blockedUserIDs).removeValue()
        } else {
            userDatabase.child(userID).updateChildValues([UserKeys.blockedUserIDs : blockedString])
        }
        
        completion(true)
    }
    
}   //  End of Class
