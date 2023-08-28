//
//  AppUser.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import UIKit

struct AppUser {
    static let unknownUserID: String = "unknownAppUser"
    static let unknownUser = AppUser(userID: unknownUserID)
    
    let userID: String
    
    var displayName: String?
    var avatarID: String?
    var avatarImage: MarketImage?
    
    init(
        userID: String,
        displayName: String? = nil,
        avatarID: String? = nil,
        avatarImage: MarketImage? = nil
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
            avatarImage: MarketImage(uid: UUID().uuidString, image: UIImage(named: "BenAvatar")!)
        ),
        
        AppUser(
            userID: "dummyUser2",
            displayName: "Steve Blue",
            avatarID: "SteveAvatar",
            avatarImage: MarketImage(uid: UUID().uuidString, image: UIImage(named: "SteveAvatar")!)
        ),
        
        AppUser(
            userID: "dummyUser3",
            displayName: "Woody Pride",
            avatarID: "WoodyAvatar",
            avatarImage: MarketImage(uid: UUID().uuidString, image: UIImage(named: "WoodyAvatar")!)
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
        
        var marketImage: MarketImage?
                
        if
            let imageData = Default.userAvatarImage.value as? Data,
            let image = UIImage(data: imageData)
        {
            marketImage = MarketImage(uid: MarketImage.userAvatarID, image: image)
        }
        
        currentUser = AppUser(
            userID: id,
            displayName: Default.userDisplayName.value as? String,
            avatarID: nil,
            avatarImage: marketImage
        )
    }
}
