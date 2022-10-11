//
//  BuyDetailCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/6/22.
//

import Foundation
import Combine

// MARK: - ViewController

class BuyDetailViewModel: ViewModel<BuyDetailCoordinator.Action> {
    @Published var item: MarketItemV2
    
    init(item: MarketItemV2) {
        self.item = item
    }
}

// MARK: - Coordinator

class BuyDetailCoordinator: Coordinator<BuyDetailCoordinator.Action> {
    
    // MARK: - Actions
    
    enum Action {}
    
    // MARK: - UIActions
    
    enum UIAction {}
    
    // MARK: - Properties
    
    let userInterface = PassthroughSubject<UIAction, Never>()
    let viewModel: BuyDetailViewModel
    
    // MARK: - Initialization
    
    init(item: MarketItemV2) {
        viewModel = BuyDetailViewModel(item: item)
        
        super.init()
        
        merge(with: viewModel)
            .receive(on: dispatchQueue)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
        
        start()
    }
}

// MARK: - Action Methods

extension BuyDetailCoordinator {
    func perform(action: Action) {
        switch action {}
    }
}

//  MARK: - Private Methods

extension BuyDetailCoordinator {
    private func start() {
        // simple check to see if additional images have been fetched yet
        if viewModel.item.images.count < 2 {
            viewModel.item.fetchAdditionalImages()
        }
    }
}

