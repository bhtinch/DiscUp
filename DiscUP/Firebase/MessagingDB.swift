//
//  MessagingDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

struct MessagingKeys {
    static let conversations = "conversations"
    static let messages = "messages"
    static let itemID = "itemID"
}

class MessagingDB {
    static let shared = MessagingDB()
    let dbRef = Database.database(url: "https://discup-messaging-rtdb.firebaseio.com/").reference()
}   //  End of Class
