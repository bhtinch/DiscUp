//
//  MessagesViewController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Foundation

class MessagesVC: BaseHostingController <MessagesRootView> {
    
    // MARK: - Private
    let coordinator: MessagesCoordinator
    
    // MARK: - Initialization
    
    init() {
        coordinator = MessagesCoordinator()
        let homeView = MessagesRootView(viewModel: coordinator.viewModel)
        
        super.init(rootView: homeView)
        
        coordinator
            .userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Action Methods

extension MessagesVC {
    private func perform(action: MessagesCoordinator.UIAction) {
        switch action {
        }
    }
}
