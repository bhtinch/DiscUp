//
//  LogInViewController.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 7/19/22.
//

import Foundation

class LogInViewController: BaseHostingController <LogInRootView> {
    
    // MARK: - Private
    
    private let coordinator: LogInCoordinator
    
    // MARK: - Initialization
    
    init() {
        coordinator = LogInCoordinator()
        let rootView = LogInRootView(viewModel: coordinator.viewModel)
        
        super.init(rootView: rootView)
        
        coordinator.userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.handle(action: $0)
            }
            .store(in: &cancellables)
    }
}

//  MARK: - Action Methods

extension LogInViewController {
    private func handle(action: LogInCoordinator.UIAction) {
        switch action {
        case .dismiss: dismiss(animated: true)
        }
    }
}
