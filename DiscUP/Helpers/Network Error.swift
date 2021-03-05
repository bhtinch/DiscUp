//
//  Network Error.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import Foundation

enum NetworkError: LocalizedError {
    case databaseError
    case noData
    
    var errorDescription: String? {
        switch self {
        case .databaseError:
            return "Error reaching database"
        case .noData:
            return "No data fetched"
        }
    }
}
