//
//  EditDetailViews.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/15/22.
//

import SwiftUI

enum SellEditOption: CaseIterable {
    case details
    case images
    
    var buttonTitle: String {
        switch self {
        case .details:  return "Edit Details"
        case .images:   return "Edit Photos"
        }
    }
    
    var buttonIcon: Image {
        switch self {
        case .details:  return Image(systemName: "line.3.horizontal")
        case .images:   return Image(systemName: "photo.fill")
        }
    }
}
