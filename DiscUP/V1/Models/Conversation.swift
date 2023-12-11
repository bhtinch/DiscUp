//
//  Conversation.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/20/21.
//

import Foundation

struct Conversation {
    let id: String
    let itemID: String
    let sellerID: String
    let buyerID: String
    var messages: [MKmessage]
    let createdDate: Date
    var itemHeadline: String
    var thumbImageID: String
}

struct ConversationBasic {
    let id: String
    var newMessages: Int
    let sellerID: String
    let buyerID: String
    let itemID: String
    var itemHeadline: String
    var thumbImageID: String
}
