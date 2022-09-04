//
//  ProfileCoordinator.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/3/22.
//

import Combine
import Foundation

//  MARK: - ViewModel
class ProfileViewModel: ViewModel<ProfileCoordinator.Action> {
    @Published var options: [ProfileOption] = ProfileOption.options
}

//  MARK: - Coordinator
class ProfileCoordinator: Coordinator<ProfileCoordinator.Action> {
    
    //  MARK: - Actions
    enum Action {
        case settings
        case signOut
    }
    
    //  MARK: - UIActions
    enum UIAction {
        case displaySettingsVC
    }
    
    //  MARK: - Properties
    let userInterface = PassthroughSubject<UIAction, Never>()
    var viewModel: ProfileViewModel
    
    //  MARK: - Initialization
    
    override init() {
        self.viewModel = ProfileViewModel()
        
        super.init()
        
        merge(with: viewModel)
            .receive(on: dispatchQueue)
            .sink { [weak self] in
                self?.perform($0)
            }
            .store(in: &cancellables)
    }
}

//  MARK: - Action Methods
extension ProfileCoordinator {
    private func perform(_ action: Action) {
        switch action {
        case .settings: userInterface.send(.displaySettingsVC)
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
