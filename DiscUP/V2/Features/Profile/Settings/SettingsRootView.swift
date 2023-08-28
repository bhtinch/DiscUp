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
        case .notifications:    break // update notification settings in user defaults and? in firebase
        case .feedback:         break // link to app store review or developer feeback
        case .sellingLocation:  break // updates defaultSelling Location in user defaults
        }
    }
}
