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
        
        MarketManager.fetchedItemPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.viewModel.items.append($0)
                
                $0.fetchThumbImage()
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
        
        fetchItems(for: viewModel.searchText)
    }
}

//  MARK: - Private Methods

extension BuyCoordinator {
    private func loadStartingItems() {
        fetchItems(for: nil)
    }
    
    private func fetchItems(for searchTerm: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.items = []
        }
        
        let searchLocation = searchLocation ?? defaultSearchLocation
        
        MarketManager.fetchItems(
            searchText: searchTerm,
            searchPostingDate: Date(),
            searchLocation: searchLocation,
            radiusMeters: viewModel.searchRange.convertToMeters,
            sellerID: nil
        )
    }
}
