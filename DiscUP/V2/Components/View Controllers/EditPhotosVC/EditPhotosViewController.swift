//
//  PhotoPickerViewController.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 4/13/22.
//

import UIKit
import SwiftUI

// MARK: - EditPhotosViewController

class EditPhotosViewController: BaseHostingController <EditPhotosRootView> {
    
    // MARK: - Private
    
    private let coordinator: EditPhotosCoordinator
    
    // MARK: - Initialization
    
    init(item: Binding<MarketItemV2>) {
        coordinator = EditPhotosCoordinator(item: item)
        let root = EditPhotosRootView(viewModel: coordinator.viewModel)
        
        super.init(rootView: root)
        
        coordinator
            .userInterface
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.perform(action: $0)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Action Methods

extension EditPhotosViewController {
    private func perform(action: EditPhotosCoordinator.UIAction) {
        switch action {
        case .dismiss: dismiss(animated: true)
        }
    }
}
