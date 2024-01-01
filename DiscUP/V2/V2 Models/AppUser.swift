//
//  AppUser.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit

struct AppUser {
    static let unknownUserID: String = "unknownAppUser"
    static let unknownUser = AppUser(userID: unknownUserID, avatarImage: AvatarImage(id: UUID().uuidString, imageURL: nil))
    
    let userID: String
    
    var displayName: String?
    var avatarID: String?
    var avatarImage: AvatarImage
    
    init(
        userID: String,
        displayName: String? = nil,
        avatarID: String? = nil,
        avatarImage: AvatarImage
    ) {
        self.userID = userID
        self.displayName = displayName
        self.avatarID = avatarID
        self.avatarImage = avatarImage
    }
    
    static let users: [AppUser] = [
        AppUser(
            userID: "dummyUser1",
            displayName: "Ben Tincher",
            avatarID: "BenAvatar",
            avatarImage: AvatarImage(id: UUID().uuidString, imageURL: nil)
        ),
        
        AppUser(
            userID: "dummyUser2",
            displayName: "Steve Blue",
            avatarID: "SteveAvatar",
            avatarImage: AvatarImage(id: UUID().uuidString, imageURL: nil)
        ),
        
        AppUser(
            userID: "dummyUser3",
            displayName: "Woody Pride",
            avatarID: "WoodyAvatar",
            avatarImage: AvatarImage(id: UUID().uuidString, imageURL: nil)
        )
    ]
    
    static var randomDummyUser: AppUser {
        users[(0..<3).randomElement()!]
    }
}

extension AppUser {
    static var currentUser: AppUser?
    
    // setCurrentUser() called in vdl of MainTabBarController
    static func setCurrentUser() {
        guard let id = Default.userID.value as? String else { return }
        
        StorageManager.downloadURLFor(imageID: id) { result in
            switch result {
            case .success(let url):
                currentUser = AppUser(
                    userID: id,
                    displayName: Default.userDisplayName.value as? String,
                    avatarID: nil,
                    avatarImage: AvatarImage(id: id, imageURL: url)
                )
                
            case .failure(let failure):
                currentUser = AppUser(
                    userID: id,
                    displayName: Default.userDisplayName.value as? String,
                    avatarID: nil,
                    avatarImage: AvatarImage(id: id, imageURL: nil)
                )
            }
        }
    }
}
