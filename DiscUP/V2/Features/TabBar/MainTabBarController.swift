//
//  MainTabBarController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import UIKit

class MainTabBarController: BaseTabBarController {
    
    // MARK: - Properties
    
    private var tabBarViewControllers: [UIViewController] {
        TabBarConstants.allCases.compactMap {
            let navController = UINavigationController(rootViewController: $0.viewController)
            navController.navigationBar.prefersLargeTitles = $0.prefersLargeTitles

            return navController
        }
        
//        TabBarConstants.allCases.map { $0.viewController }
    }
    
    // MARK: - Initialization
    
    override init() {
        
        super.init()
        
        setUp()
        setSubs()
    }
    
    //  MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuth()
    }
}

//  MARK: - Set Up

extension MainTabBarController {
    private func setUp() {
        UITabBar.appearance().backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().unselectedItemTintColor = .gray
        UITabBar.appearance().tintColor = AppTheme.Colors.mainAccent.uiColor
//        UITabBar.appearance().tintColor = .systemTeal
        UITabBar.appearance().isTranslucent = true

        self.setViewControllers(tabBarViewControllers, animated: true)
    }
    
    private func setSubs() {
//        App.authManager.userSignedOutPublisher
//            .receive(on: RunLoop.main)
//            .sink { [weak self] in
//                self?.presentAuthVC()
//            }
//            .store(in: &cancellables)
    }
}

// MARK: - Private Methods

extension MainTabBarController {
    private func checkAuth() {
        if !AuthManager.userLoggedIn {
            presentAuthVC()
        }
    }
    private func presentAuthVC() {
        selectedIndex = 0
        
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: false)
    }
}

