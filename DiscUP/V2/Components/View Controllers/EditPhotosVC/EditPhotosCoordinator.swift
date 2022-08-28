//
//  EditPhotosCoordinator.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 4/24/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI

// MARK: - ViewController

class EditPhotosViewModel: ViewModel<EditPhotosCoordinator.Action> {
    @Binding var item: MarketItemV2

    let originalItem: MarketItemV2

    init(item: Binding<MarketItemV2>) {
        self._item = item
        self.originalItem = item.wrappedValue

        super.init()
    }
}

// MARK: - Coordinator

class EditPhotosCoordinator: Coordinator<EditPhotosCoordinator.Action> {

    // MARK: - Actions

    enum Action {
        case delete(String)
        case setAsThumbnail(String)
        case addPhoto(UIImage)
        case cancel
        case save
    }

    // MARK: - UIActions

    enum UIAction {
        case dismiss
    }

    // MARK: - Properties

    let userInterface = PassthroughSubject<UIAction, Never>()
    let viewModel: EditPhotosViewModel

    // MARK: - Initialization

    init(item: Binding<MarketItemV2>) {
        viewModel = EditPhotosViewModel(item: item)

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

private extension EditPhotosCoordinator {
    func perform(action: Action) {
        switch action {
        case .delete(let imageID):
            deleteAction(imageID: imageID)

        case .setAsThumbnail(let imageID):
            setAsThumbnailAction(imageID: imageID)

        case .addPhoto(let image):
            addPhotosAction(image: image)

        case .cancel:   cancelAction()
        case .save:     saveAction()
        }
    }

    func deleteAction(imageID: String) {
        debugPrint("delete \(imageID)")
    }

    func setAsThumbnailAction(imageID: String) {
        debugPrint("set thumb \(imageID)")
    }

    func addPhotosAction(image: UIImage) {
        debugPrint("add photo")
    }

    func cancelAction() {
        userInterface.send(.dismiss)
    }

    func saveAction() {
        debugPrint("save action")
        cancelAction()
    }
}
