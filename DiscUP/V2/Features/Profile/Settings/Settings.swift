//
//  Settings.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/12/22.
//

import Foundation

enum SettingType: Int, CaseIterable {
    case notifications
    case feedback
    case sellingLocation
}

struct Setting: Identifiable {
    var id = UUID()
    let type: SettingType
    var title: String

    static var settings = [
        Setting(type: .notifications, title: "Notifications"),
        Setting(type: .feedback, title: "Rate App"),
        Setting(type: .sellingLocation, title: "Default Selling Location")
    ]
}
