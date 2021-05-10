//
//  MarketDB.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/10/21.
//

import Foundation
import Firebase

struct MarketKeys {
    static let conversations = "conversations"
    static let owner = "owner"
}

class MarketDB {
    static let shared = MarketDB()
    let dbRef = Database.database(url: "https://discup-market-rtdb.firebaseio.com/").reference()
}   //  End of Class
