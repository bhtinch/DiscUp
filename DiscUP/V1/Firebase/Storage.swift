//
//  Storage.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import FirebaseStorage
import Foundation

class StorageManager {
    static let storage = Storage.storage().reference()
    
    private static var userID: String? {
        AuthManager.auth.currentUser?.uid
    }
    
    static func upload(images: [MarketImage]) async throws {
        for i in 0..<images.count {
            guard
                let data = images[i].uiImage.pngData()
            else { return }
            
            _ = try await storage.child("\(images[i].id)").putDataAsync(data)
        }
    }
    
    static func upload(images: [MarketImage], completion: ((Error?) -> Void)?) {
        for i in 0..<images.count {
            guard
                let data = images[i].uiImage.pngData()
            else { return }
            
            storage.child("\(images[i].id)").putData(data) { _, error in
                completion?(error)
            }
        }
    }
    
    static func uploadImagesWith(images: [UIImage], completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        for image in images {
            guard let filename = image.accessibilityIdentifier,
                  let data = image.pngData() else { return completion(.failure(NetworkError.databaseError)) }
            storage.child(filename).putData(data, metadata: nil) { _, error in
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(.failure(NetworkError.failedToUploadToStorage))
                }
                
                if image == images.last {
                    return completion(.success(true))
                }
            }
        }
    }
    
    static func downloadURLFor(imageID: String, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        storage.child(imageID).downloadURL { url, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.failedToGetDownloadURL))
            }
            
            guard let url = url else { return completion(.failure(NetworkError.failedToGetDownloadURL)) }
            completion(.success(url))
        }
    }
    
    static func deleteImagesWith(imageIDs: [String], completion: @escaping (Bool) -> Void) {
        for id in imageIDs {
            storage.child(id).delete { error in
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(false)
                }
                
                if id == imageIDs.last { completion(true) }
            }
        }
    }
}
