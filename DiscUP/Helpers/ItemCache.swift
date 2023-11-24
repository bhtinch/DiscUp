//
//  ItemCache.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/4/23.
//

import Foundation

class ItemCache {
    static let shared = ItemCache()
    
    let cache = NSCache<NSString, MarketItemV2>()
    
    func insert(_ item: MarketItemV2) {
        cache.setObject(item, forKey: item.id.nsString())
    }
    
    func getItem(with itemID: String) -> MarketItemV2? {
        cache.object(forKey: itemID.nsString())
    }
    
    func containsItem(withID itemID: String) -> Bool {
        cache.object(forKey: itemID.nsString()) != nil
    }
    
    private init() {}
}
