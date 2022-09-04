//
//  HomeViewController.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 1/15/22.
//

import Foundation

class BuyViewController: BaseHostingController <BuyRootView>, HasSpinner {
    
    // MARK: - Private
    let coordinator: BuyCoordinator
    
    // MARK: - Initialization
    
    init() {
        coordinator = BuyCoordinator()
        let homeView = BuyRootView(viewModel: coordinator.viewModel)
        
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

extension BuyViewController {
    private func perform(uiAction: BuyCoordinator.UIAction) {
        switch uiAction {
        case .goToDetail(let item): goToDetail(for: item)
        case .handle(let error):    handle(error)
        }
    }
    
    private func goToDetail(for item: MarketItemV2) {
        let detailVC = BuyDetailViewController(item: item)
        
        present(detailVC, animated: true)
    }
    
    //  MARK: - BenDo: Handle Error
    private func handle(_ error: Error) {
        print(error.localizedDescription)
    }
}
