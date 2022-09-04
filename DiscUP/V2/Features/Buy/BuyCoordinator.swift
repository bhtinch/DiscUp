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
        case handle(Error)
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
        
        start()
    }
}

//  MARK: - Start
extension BuyCoordinator {
    private func start() {
        loadStartingItems()
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

//  MARK: - Private Methods

extension BuyCoordinator {
    private func loadStartingItems() {
        MarketManager.fetchOfferIDsWithin(range: "", of: Location.userCurrentLocation ?? Location.defaultLocation) { [weak self] result in
            switch result {
            case .failure(let error):   self?.userInterface.send(.handle(error))
            case .success(let itemIDs): self?.fetchItems(with: itemIDs)
            }
        }
    }

    private func fetchItemIDs() {}
    
    private func fetchItems(with itemIDs: [String]) {
        debugPrint(itemIDs.count)
    }
}
