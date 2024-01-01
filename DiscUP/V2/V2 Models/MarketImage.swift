//
//  MarketImage.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit
import Observation

class MarketImage: Observable, Identifiable {
    var id: String
    var imageURL: URL?
    var imageData: Data?
//    var isThumbImage: Bool
    
    var itemImageView: ItemImageView {
        ItemImageView(imageURL: imageURL)
    }
    
    init(uid: String, imageURL: URL? = nil, imageData: Data? = nil) {
        id = uid
        self.imageURL = imageURL
        self.imageData = imageData
    }
    
    static var defaultNoImage = MarketImage (uid: "defaultNoImageUID", imageURL: nil)
    static let userAvatarID = "userAvatarID"
}

class AvatarImage: Identifiable {
    var id: String
    var imageURL: URL?
    var imageData: Data?
    
    var imageView: AvatarImageView {
        AvatarImageView(imageURL: imageURL)
    }
    
    init(id: String, imageURL: URL? = nil, imageData: Data? = nil) {
        self.id = id
        self.imageURL = imageURL
        self.imageData = imageData
    }
}
