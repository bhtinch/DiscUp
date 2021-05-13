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
    
}
