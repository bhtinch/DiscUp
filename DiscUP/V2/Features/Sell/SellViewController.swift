//
//  SellViewController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Foundation

class SellViewController: BaseHostingController <SellRootView> {
    
    // MARK: - Private
    let coordinator: SellCoordinator
    
    // MARK: - Initialization
    
    init() {
        coordinator = SellCoordinator()
        let homeView = SellRootView(viewModel: coordinator.viewModel)
        
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

extension SellViewController {
    private func perform(uiAction: SellCoordinator.UIAction) {
        switch uiAction {
        case .goToDetail(let item):
            goToDetail(for: item)
            
        case .presentNewItemVC:
            goToNewItemVC()
        }
    }
    
    private func goToDetail(for item: MarketItemV2) {
        let detailVC = SellDetailViewController(item: item)
        
        present(detailVC, animated: true)
    }
    
    private func goToNewItemVC() {
        let newItemVC = SellNewItemViewController()
        
        present(newItemVC, animated: true)
    }
}
