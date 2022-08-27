//
//  BuyDetailViewController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/6/22.
//

import Foundation

class BuyDetailViewController: BaseHostingController <BuyDetailRootView> {
    
    // MARK: - Private
    let coordinator: BuyDetailCoordinator
    
    // MARK: - Initialization
    
    init(item: MarketItemV2) {
        coordinator = BuyDetailCoordinator(item: item)
        
        let homeView = BuyDetailRootView(viewModel: coordinator.viewModel)
        
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

extension BuyDetailViewController {
    private func perform(action: BuyDetailCoordinator.UIAction) {
        switch action {
        }
    }
}
