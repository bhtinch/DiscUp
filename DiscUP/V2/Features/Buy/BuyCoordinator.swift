//
//  HomeCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 1/16/22.
//

import Combine
import SwiftUI

// MARK: - View Model

class BuyViewModel: ViewModel<BuyCoordinator.Action> {
    @Published var title: String = "Market Place"
    @Published var items: [MarketItemV2] = MarketItemV2.items
    @Published var searchText: String = ""
    
    @Published var selectedItem: MarketItemV2 = MarketItemV2.defaultNoItem {
        didSet {
            send(.itemSelected(selectedItem))
        }
    }
}

// MARK: - Coordinator

class BuyCoordinator: Coordinator<BuyCoordinator.Action> {
    
    // MARK: - UIActions
    
    enum UIAction {
        case goToDetail(MarketItemV2)
    }
    
    // MARK: - Action
    
    enum Action {
        case searchSubmitted
        case itemSelected(MarketItemV2)
    }
    
    // MARK: - Properties
    
    let viewModel: BuyViewModel
    let userInterface = PassthroughSubject<UIAction, Never>()
    
    // MARK: - Initialization
    
    override init() {
        viewModel = BuyViewModel()
        
        super.init()
        
        merge(with: viewModel)
            .receive(on: dispatchQueue)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Action Methods

extension BuyCoordinator {
    private func perform(action: Action) {
        switch action {
        case .searchSubmitted:
            searchSubmittedAction()
            
        case .itemSelected(let item):
            userInterface.send(.goToDetail(item))
        }
    }
    
    private func searchSubmittedAction() {
        guard !viewModel.searchText.isEmpty else { return }
        
        debugPrint(viewModel.searchText)
        // BenDo: 
        // FB search and return values
        // update items on viewModel
    }
}
