//
//  Extensions.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import MessageKit

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
}

extension String {
    func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
    }
    
    func createTwoNames() -> [String] {
        var array = self.components(separatedBy: " ")
        
        if array.count == 1 {
            array.append("")
            array.reverse()
            return array
            
        } else {
            let first = array.removeFirst()
            let last = array.joined(separator: " ")
            
            return [first, last]
        }
    }
}

extension UIImage {
    func asMediaItem() -> MediaItem {
        ImageMediaItem(image: self)
    }
}
