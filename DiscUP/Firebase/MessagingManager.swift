//
//  MessagingManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

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
            ConversationKeys.createdDate : Date().convertToUTCString(format: .fullNumericWithTimezone)
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
            userDatabase.child("\(buyerID)/\(UserKeys.buyingMessages)").updateChildValues([item.id : convoID])
            
            //  add convoID ref to seller's 'sellingMessages'
            userDatabase.child("\(sellerID)/\(UserKeys.sellingMessages)").updateChildValues([item.id : convoID])
            
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
        ]) {error, _ in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(false)
            }
            
            completion(true)
        }
    }
    
}   //  End of Class


	
	
