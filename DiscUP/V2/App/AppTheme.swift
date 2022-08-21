//
//  AppTheme.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import UIKit
import SwiftUI

// MARK: - Theme Constants

enum AppTheme {
    enum Colors: String {
        case mainAccent
        case secondaryAccent
        case tertiaryAccent
        
        case text
        
        var uiColor: UIColor {
            switch self {
            case .text: return .label
            default:    return UIColor(named: self.rawValue) ?? UIColor()
            }
        }
        
        var color: Color {
            Color(self.rawValue)
        }
    }
    
    enum Fonts {
        static let text: UIFont         = .systemFont(ofSize: 10)
        static let semiboldText: UIFont = .systemFont(ofSize: 10, weight: .semibold)
        static let boldText: UIFont     = .systemFont(ofSize: 10, weight: .bold)
    }
}

// MARK: - Features
 
extension AppTheme {
    enum Features {
        enum TabBar {
            enum Colors {
                case barTintColor
                case tintColor
                case unselectedItem
                
                var uiColor: UIColor {
                    switch self {
                    case .barTintColor:     return AppTheme.Colors.mainAccent.uiColor
                    case .tintColor:        return AppTheme.Colors.secondaryAccent.uiColor
                    case .unselectedItem:   return AppTheme.Colors.text.uiColor
                    }
                }
            }
            
            static let font: UIFont = AppTheme.Fonts.text
        }
    }
}
