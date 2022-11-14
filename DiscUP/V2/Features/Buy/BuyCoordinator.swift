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
    @Published var searchRangeValue: Int = 10
    @Published var searchRange: SearchRange = .kilometers(10)
    
    // dummy items
//    @Published var items: [MarketItemV2] = MarketItemV2.items
    
    @Published var items: [MarketItemV2] = []
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
    
    //  MARK: - Search Properties
    
    /// default searching Location if no manual one is specified on property 'searchLocation'
    var defaultSearchLocation: Location
    
    /// manually applied searching Location
    var searchLocation: Location?
    
    /// set searching radius in miles from searching location
    var searchRangeMiles: Int = 10
    
    // MARK: - Initialization
    
    override init() {
        viewModel = BuyViewModel()
        
        defaultSearchLocation = Location.userCurrentLocation ?? Location.defaultLocation
        
        super.init()
        
        merge(with: viewModel)
            .receive(on: dispatchQueue)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
        
        setSubs()
        start()
    }
    
    private func setSubs() {
        LocationManager.shared.authStatusChanged
            .sink { [weak self] in
                if $0 == .authorizedWhenInUse || $0 == .authorizedAlways {
                    self?.defaultSearchLocation = Location.userCurrentLocation ?? Location.defaultLocation
                } else {
                    self?.defaultSearchLocation = Location.defaultLocation
                }
            }
            .store(in: &cancellables)
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
        let searchLocation = searchLocation ?? defaultSearchLocation
        
        MarketManager.fetchOfferIDsWithin(
            range: viewModel.searchRange,
            of: searchLocation
        ) { [weak self] result in
            switch result {
            case .failure(let error):   self?.userInterface.send(.handle(error))
            case .success(let itemIDs): self?.fetchItems(with: itemIDs)
            }
        }
    }
    
    private func fetchItems(with itemIDs: [String]) {
        debugPrint(itemIDs.count)
        
        for id in itemIDs {
            MarketManager.fetchItemWith(itemID: id) { [weak self] item in
                guard
                    let item = item,
                    let itemV2 = MarketItemV2(marketItem: item, type: .disc)
                else { return }
                
                self?.viewModel.items.append(itemV2)
                
                itemV2.fetchThumbImage()
            }
        }
    }
}
