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
    case invalidURL
    case thrownError(Error)
    case unableToDecode
    case unableToLogin
    
    var errorDescription: String? {
        switch self {
        case .databaseError:
            return "Error reaching database"
        case .thrownError(let error):
            return "Error: \(error.localizedDescription) -> \(error)"
        case .invalidURL:
            return "Unable to reach the server."
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        case .unableToLogin:
            return "Could not login."
        }
    }
}
