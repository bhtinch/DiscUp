//
//  SettingsViewController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Combine
import Foundation

class SettingsVC: BaseHostingController <SettingsRootView> {
    
    // MARK: - Private
    let coordinator: SettingsCoordinator
    
    // MARK: - Initialization
    
    init() {
        coordinator = SettingsCoordinator()
        let homeView = SettingsRootView(viewModel: coordinator.viewModel)
        
        super.init(rootView: homeView)
        
        coordinator
            .userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.perform(uiAction: $0)
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Action Methods

extension SettingsVC {
    private func perform(uiAction: SettingsCoordinator.UIAction) {
        switch uiAction {
        }
    }
}
