//
//  MarketImage.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit

class MarketImage: Identifiable {
    var id: String
    var uiImage: UIImage
    var isThumbImage: Bool
    
    init(uid: String, image: UIImage, isThumbImage: Bool = false) {
        id = uid
        uiImage = image
        self.isThumbImage = isThumbImage
    }
    
    static var defaultNoImage = MarketImage (uid: "defaultNoImageUID", image: UIImage(named: "logo2") ?? UIImage(), isThumbImage: true)
}
