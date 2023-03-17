//
//  SellNewItemCoordinator.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/17/22.
//

import Foundation
import Combine
import SwiftUI

// MARK: - View Model

class SellNewItemViewModel: ViewModel <SellNewItemCoordinator.Action> {
    @Published var pageIndex = 0
    
    @Published var nextButtonDisabled = true
    
    @Published var item: MarketItemV2
    
    init(item: MarketItemV2) {
        self.item = item
    }
}

// MARK: - Coordinator

class SellNewItemCoordinator: Coordinator <SellNewItemCoordinator.Action> {
    
    // MARK: - UIActions
    
    enum UIAction {
        case dismiss
    }
    
    // MARK: - Action
    
    enum Action {
        case cancelTapped
        case saveTapped
    }
    
    // MARK: - Properties
    
    let viewModel: SellNewItemViewModel
    let userInterface = PassthroughSubject<UIAction, Never>()
    
    // MARK: - Initialization
    
    init(appUser: AppUser) {
        /* Ben do:
         - need to set default seller prop as current user (user defaults)
         - need to get current users default selling location (user defaults)
         - not sure if any generic uuid will do... may want some other form of a uuid later
         
         */
        
        let newItem = MarketItemV2(
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
            seller: appUser
        )
        
        viewModel = SellNewItemViewModel(item: newItem)
        
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

extension SellNewItemCoordinator {
    private func perform(action: Action) {
        switch action {
        case .cancelTapped:
            userInterface.send(.dismiss)
            
        case .saveTapped:
            saveNewItem()
        }
    }
    
    private func saveNewItem() {
        Task {
            //  MARK: - BenDo: Handle failure
            do {
                try await MarketManager.add(item: viewModel.item)
                userInterface.send(.dismiss)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
