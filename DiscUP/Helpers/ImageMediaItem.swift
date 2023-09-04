//
//  ImageMediaItem.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/30/23.
//

import UIKit
import MessageKit

class ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    internal init(url: URL? = nil, image: UIImage? = nil, placeholderImage: UIImage = UIImage(), size: CGSize? = nil) {
        self.url = url
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size ?? image?.size ?? placeholderImage.size
    }
}
