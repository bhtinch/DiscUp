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
    case noUser
    case failedToUploadToStorage
    case failedToGetDownloadURL
    
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
        case .noUser:
            return "No user logged in"
        case .failedToUploadToStorage:
            return "Failed to upload the media to Firebase Storage"
        case .failedToGetDownloadURL:
            return "Failed to get a download URL from Firebase Storage"
        }
    }
}
