//
//  SettingsRootView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import SwiftUI

struct SettingsRootView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: SettingsViewModel
    
    // MARK: - Body
    
    var body: some View {
        List($viewModel.settings) { setting in
            Button(setting.wrappedValue.title) {
                performAction(setting: setting.wrappedValue.type)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }
}

struct SettingsRootView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRootView(viewModel: SettingsViewModel())
    }
}

//  MARK: - Private Methods

extension SettingsRootView {
    private func performAction(setting: SettingType) {
        switch setting {
        case .profile:          break
        case .notifications:    break
        case .feedback:         break
        case .logOut:           viewModel.send(.signOut)
        }
    }
}
