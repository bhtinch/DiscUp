//
//  SettingsCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import Combine
import Foundation

// MARK: - ViewController

class SettingsViewModel: ViewModel<SettingsCoordinator.Action> {
    @Published var settings: [Setting] = Setting.settings
}

// MARK: - Coordinator

class SettingsCoordinator: Coordinator<SettingsCoordinator.Action> {
    
    // MARK: - Actions
    
    enum Action {
        case signOut
    }
    
    // MARK: - UIActions
    
    enum UIAction {}
    
    // MARK: - Properties
    
    let userInterface = PassthroughSubject<UIAction, Never>()
    let viewModel: SettingsViewModel
    
    // MARK: - Initialization
    
    override init() {
        viewModel = SettingsViewModel()
        
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

extension SettingsCoordinator {
    func perform(action: Action) {
        switch action {
        case .signOut: signOutAction()
        }
    }
    
    private func signOutAction() {
        //  MARK: - present log out confirmation alert
        //  MARK: - BENDO: handle error in sign out
        guard AuthManager.logoutUser() else { return }
        
        AuthManager.userSignedOutPublisher.send()
    }
}

