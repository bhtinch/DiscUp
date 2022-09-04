//
//  ProfileViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/3/22.
//

import Combine
import UIKit

class ProfileViewControllerV2: BaseHostingController<ProfileRootView> {
    // MARK: - Private
    let coordinator: ProfileCoordinator
    
    // MARK: - Initialization
    init() {
        coordinator = ProfileCoordinator()
        let homeView = ProfileRootView(viewModel: coordinator.viewModel)
        
        super.init(rootView: homeView)
        
        coordinator
            .userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.perform(uiAction: $0)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Action Methods

extension ProfileViewControllerV2 {
    private func perform(uiAction: ProfileCoordinator.UIAction) {
        switch uiAction {
        case .displaySettingsVC: displaySettingsVCAction()
        }
    }
    
    private func displaySettingsVCAction() {
        let vc = SettingsVC()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
