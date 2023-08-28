//
//  LogInCoordinator.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 7/19/22.
//

import Foundation
import Combine

// MARK: - View Model

class LogInViewModel: ViewModel <LogInCoordinator.Action> {
    @Published var usernameAvailable = true
}

// MARK: - Coordinator

class LogInCoordinator: Coordinator <LogInCoordinator.Action> {
    
    // MARK: - UIActions
    
    enum UIAction {
        case dismiss
    }
    
    // MARK: - Action
    
    enum Action {
        case signInWith(_ email: String, _ password: String)
        
        case didInputUsername(String)
        
        case signUpWith(
            _ email: String,
            _ username: String,
            _ firstName: String,
            _ lastName: String,
            _ password: String
        )
    }
    
    // MARK: - Properties
    
    let viewModel: LogInViewModel
    let userInterface = PassthroughSubject<UIAction, Never>()
    
    // MARK: - Initialization
    
    override init() {
        viewModel = LogInViewModel()
        
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

extension LogInCoordinator {
    private func perform(action: Action) {
        switch action {
        case .signInWith(let email, let password):
            signInWith(email, password)
            
        case .didInputUsername(let username):
            checkUsernameAvailability(username)
            
            
        case .signUpWith(let email, let username, let firstName, let lastName, let password):
            signUpWith(email, username, firstName, lastName, password)
        }
    }
    
    private func signInWith(_ email: String, _ password: String) {
        AuthManager.loginUserWith(email: email, password: password) { [weak self] success in
            guard success else { return }
            //  MARK: - BenDo: handle success and failure
            
            self?.userInterface.send(.dismiss)
        }
    }
    
    private func checkUsernameAvailability(_ username: String) {
        //  MARK: - BenDo: Add this method
//        viewModel.usernameAvailable = AuthManager.checkUsernameAvailability(username)
    }
    
    private func signUpWith(
        _ email: String,
        _ username: String,
        _ firstName: String,
        _ lastName: String,
        _ password: String
    ) {
        let firstName: String? = firstName == "" ? nil : firstName
        let lastName: String? = lastName == "" ? nil : lastName
        
        AuthManager.registerNewUserWith(email: email, password: password, username: username, firstName: firstName, lastName: lastName) { success in
            guard success else { return }
            //  MARK: - BenDo: handle success and failure
            
            self.userInterface.send(.dismiss)
        }
    }
}
