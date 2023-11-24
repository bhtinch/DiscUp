//
//  General Error.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/4/23.
//

import Foundation

enum DescriptiveError: LocalizedError {
    case couldNotCreateMarketItemModelFromDataModel
    
    var errorDescription: String?  {
        switch self {
        case .couldNotCreateMarketItemModelFromDataModel: return "Could not create a MarketItemV2 object from the MarketItemDataModel."
        }
    }
}
