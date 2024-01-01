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
//    @Published var items: [MarketItemV2] = {
//        var arr = Array(MarketItemV2.items.prefix(3))
//        
//        arr.append(contentsOf: MarketItemV2.goodItems.prefix(2))
//        
//        return arr
//    }()
    
    @Published var items: [MarketItemV2] = []
    
    @Published var newItem: MarketItemV2?
    
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
        case presentCommonAlert(Alerts.Common)
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
        
        setUpSubs()
        start()
    }
    
    private func start() {
        fetchItems()
    }
    
    private func setUpSubs() {
        merge(with: viewModel)
            .receive(on: dispatchQueue)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
        
        MarketManager.fetchedItemPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.viewModel.items.append($0)
                
                $0.fetchThumbImage()
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
        guard let currentUser = AppUser.currentUser else {
            userInterface.send(.presentCommonAlert(Alerts.Common.noCurrentUser))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.newItem = MarketItemV2(
                id: "",
                headline: "",
                manufacturer: "",
                model: "",
                plastic: "",
                weight: 0,
                thumbImageID: "",
                price: 10,
                location: Location.defaultSellingLocation ?? Location.userCurrentLocation ?? Location.defaultLocation,
                itemType: .disc,
                description: "Please add a description...",
                seller: currentUser
            )
        }
        
        userInterface.send(.presentNewItemVC)
    }
}

//  MARK: - Private Methods

extension SellCoordinator {
    private func fetchItems() {
        guard let currentUser = AppUser.currentUser else { return }
        MarketManager.fetchAllItemsSoldByUser(sellerID: currentUser.userID)
    }
}

