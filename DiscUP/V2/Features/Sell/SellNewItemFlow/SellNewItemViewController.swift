//
//  SellNewItemViewController.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/17/22.
//

import Foundation

class SellNewItemViewController: BaseHostingController <SellNewItemView> {
    
    // MARK: - Private
    
    private let coordinator: SellNewItemCoordinator
    
    // MARK: - Initialization
    
    init(_ newItem: MarketItemV2) {
        coordinator = SellNewItemCoordinator(newItem)
        let rootView = SellNewItemView(viewModel: coordinator.viewModel)
        
        super.init(rootView: rootView)
        
        coordinator.userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
    }
}

//  MARK: - Private Methods

private extension SellNewItemViewController {
    func perform(action: SellNewItemCoordinator.UIAction) {
        switch action {
        case .dismiss:
            self.navigationController?.popViewController(animated: true)
            dismiss(animated: true)
        }
    }
}
