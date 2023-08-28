//
//  ProfileRootView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 9/3/22.
//

import SwiftUI

struct ProfileRootView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProfileViewModel
    
    // MARK: - Body
    
    var body: some View {
        List($viewModel.options) { option in
            Button(option.wrappedValue.title) {
                performAction(optionType: option.wrappedValue.type)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
    }
}

//  MARK: - Private Methods

extension ProfileRootView {
    private func performAction(optionType: ProfileOptionType) {
        switch optionType {
        case .settings: viewModel.send(.settings)
        case .logOut:   viewModel.send(.signOut)
        }
    }
}
