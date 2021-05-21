//
//  MessagingDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

struct ConversationKeys {
    static let messages = "messages"
    static let itemID = "itemID"
    static let buyerID = "buyerID"
    static let sellerID = "sellerID"
    static let createdDate = "createdDate"
    static let itemHeadline = "itemHeadline"
    static let thumbImageID = "thumbImageID"
    static let newMessages = "newMessages"
}

struct MessageKeys {
    static let sentDate = "sentDate"
    static let senderID = "senderID"
    static let text = "text"
    static let messageID = "messageID"
    static let senderDisplayName = "senderDisplayName"
}

class MessagingDB {
    static let shared = MessagingDB()
    let dbRef = Database.database(url: "https://discup-messaging-rtdb.firebaseio.com/").reference()
}   //  End of Class
