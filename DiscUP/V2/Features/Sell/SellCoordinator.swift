//
//  SellCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Foundation
import Combine

// MARK: - ViewController

class SellViewModel: ViewModel<SellCoordinator.Action> {
    @Published var items: [MarketItemV2] = {
        var arr = Array(MarketItemV2.items.prefix(3))
        
        arr.append(contentsOf: MarketItemV2.goodItems.prefix(2))
        
        return arr
    }()
    
    @Published var searchText: String = ""
    
    @Published var selectedItem: MarketItemV2 = MarketItemV2.defaultNoItem {
        didSet {
            send(.itemSelected(selectedItem))
        }
    }
}

// MARK: - Coordinator

class SellCoordinator: Coordinator<SellCoordinator.Action> {
    
    // MARK: - Actions
    
    enum UIAction {
        case goToDetail(MarketItemV2)
        case presentNewItemVC
    }
    
    // MARK: - UIActions
    
    enum Action {
        case searchSubmitted
        case createNew
        case itemSelected(MarketItemV2)
    }
    
    // MARK: - Properties
    
    let userInterface = PassthroughSubject<UIAction, Never>()
    let viewModel: SellViewModel
    
    // MARK: - Initialization
    
    override init() {
        viewModel = SellViewModel()
        
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

extension SellCoordinator {
    private func perform(action: Action) {
        switch action {
        case .searchSubmitted:
            searchSubmittedAction()
            
        case .createNew:
            createNewAction()
            
        case .itemSelected(let item):
            userInterface.send(.goToDetail(item))
        }
    }
    
    private func searchSubmittedAction() {
        guard !viewModel.searchText.isEmpty else { return }
        
        debugPrint(viewModel.searchText)
        // FB search and return values
        // update items on viewModel
    }
    
    private func createNewAction() {
        userInterface.send(.presentNewItemVC)
    }
}

