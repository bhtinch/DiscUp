//
//  MessagesCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Foundation
import Combine

// MARK: - ViewController

class MessagesViewModel: ViewModel<MessagesCoordinator.Action> {
    
}

// MARK: - Coordinator

class MessagesCoordinator: Coordinator<MessagesCoordinator.Action> {
    
    // MARK: - Actions
    
    enum Action {}
    
    // MARK: - UIActions
    
    enum UIAction {}
    
    // MARK: - Properties
    
    let userInterface = PassthroughSubject<UIAction, Never>()
    let viewModel: MessagesViewModel
    
    // MARK: - Initialization
    
    override init() {
        viewModel = MessagesViewModel()
        
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

extension MessagesCoordinator {
    func perform(action: Action) {
        switch action {}
    }
}

