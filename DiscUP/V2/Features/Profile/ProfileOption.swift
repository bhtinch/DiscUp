//
//  ProfileOption.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/3/22.
//

import Foundation

enum ProfileOptionType: Int, CaseIterable {
    case settings
    case logOut
}

struct ProfileOption: Identifiable {
    var id = UUID()
    let type: ProfileOptionType
    var title: String

    static var options = [
        ProfileOption(type: .settings, title: "Settings"),
        ProfileOption(type: .logOut, title: "Log Out")
    ]
}
