//
//  TabBarConstants.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import UIKit

// MARK: - TabBarConstants

enum TabBarConstants: Int, CaseIterable {
    case buy = 0
    case sell
    case messages
    case settings
    
    // MARK: - Tab Bar Elements
    
    private var title: String {
        switch self {
        case .buy:      return "Buy"
        case .sell:     return "Sell"
        case .messages: return "Messages"
        case .settings: return "Settings"
        }
    }
    
    private var image: UIImage? {
        switch self {
        case .buy:      return UIImage(systemName: "tag")
        case .sell:     return UIImage(systemName: "dollarsign.circle")
        case .messages: return UIImage(systemName: "text.bubble")
        case .settings: return UIImage(systemName: "gearshape")
        }
    }
    
    private var selectedImage: UIImage? {
        switch self {
        case .buy:      return UIImage(systemName: "tag.fill")
        case .sell:     return UIImage(systemName: "dollarsign.circle.fill")
        case .messages: return UIImage(systemName: "text.bubble.fill")
        case .settings: return UIImage(systemName: "gearshape.fill")
        }
    }
    
    private var tabItem: UITabBarItem {
        let item = UITabBarItem(title: title, image: image, tag: self.rawValue)
        
        item.selectedImage = selectedImage
        
        item.setTitleTextAttributes(
            [.font : AppTheme.Features.TabBar.font],
            for: .normal
        )
        
        return item
    }
    
    var prefersLargeTitles: Bool {
        true
    }
    
    var viewController: UIViewController {
        var vc: UIViewController?
        
        switch self {
        case .buy:      vc = BuyViewController()
        case .sell:     vc = SellViewController()            
        case .messages: vc = MessagesVC()
        case .settings: vc = SettingsVC()
        }
        
        vc?.tabBarItem = tabItem
        vc?.title = title
        
        return vc!
    }
}

