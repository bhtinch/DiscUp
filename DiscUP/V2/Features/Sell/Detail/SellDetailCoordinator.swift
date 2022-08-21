////
////  SellDetailCoordinator.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 3/15/22.
////
//
//import Foundation
//import Combine
//import SwiftUI
//
//// MARK: - ViewController
//
//class SellDetailViewModel: ViewModel<SellDetailCoordinator.Action> {
//    @Published var item: MarketItem {
//        didSet {
//            hasChanges =
//            item.imageIDs           != originalItem.imageIDs            ||
//            item.itemType           != originalItem.itemType            ||
//            item.price              != originalItem.price               ||
//            item.thumbImageID       != originalItem.thumbImageID        ||
//            item.plastic            != originalItem.plastic             ||
//            item.manufacturer       != originalItem.manufacturer        ||
//            item.headline           != originalItem.headline            ||
//            item.location.latitude  != originalItem.location.latitude   ||
//            item.location.longitude != originalItem.location.longitude  ||
//            item.description        != originalItem.description         ||
//            item.model              != originalItem.model
//        }
//    }
//    
//    @Published var hasChanges: Bool = false
//    
//    let originalItem: MarketItem
//    
//    init(item: MarketItem) {
//        self.item = item
//        originalItem = item
//    }
//}
//
//// MARK: - Coordinator
//
//class SellDetailCoordinator: Coordinator<SellDetailCoordinator.Action> {
//    
//    // MARK: - Actions
//    
//    enum Action {
//        case editPhotosTapped(Binding<MarketItem>)
//        case dismiss(save: Bool)
//        case deleteItem
//        case update(editableValue: MarketItemEditableValue, value: Any, shouldDismiss: Bool)
//    }
//    
//    // MARK: - UIActions
//    
//    enum UIAction {
//        case presentEditPhotos(Binding<MarketItem>)
//        case dismiss
//    }
//    
//    // MARK: - Properties
//    
//    let userInterface = PassthroughSubject<UIAction, Never>()
//    let viewModel: SellDetailViewModel
//    
//    // MARK: - Initialization
//    
//    init(item: MarketItem) {
//        viewModel = SellDetailViewModel(item: item)
//        
//        super.init()
//        
//        merge(with: viewModel)
//            .receive(on: dispatchQueue)
//            .sink { [weak self] in
//                self?.perform(action: $0)
//            }
//            .store(in: &cancellables)
//    }
//}
//
//// MARK: - Action Methods
//
//extension SellDetailCoordinator {
//    func perform(action: Action) {
//        switch action {
//        case .editPhotosTapped(let _item):
//            userInterface.send(.presentEditPhotos(_item))
//            
//        case .dismiss(save: let shouldSave):
//            dismissAction(shouldSave: shouldSave)
//            
//        case .deleteItem:
//            deleteItemAction()
//            
//        case .update(let editableValue, let value, let shouldDismiss):
//            updateAction(
//                editableValue: editableValue,
//                value: value,
//                shouldDismiss: shouldDismiss
//            )
//        }
//    }
//    
//    private func dismissAction(shouldSave: Bool) {
//        if shouldSave {
//            // BenDo: update DB
//        // some manager or something update the object in local persist and FB or whatever is needed
//        }
//        
//        userInterface.send(.dismiss)
//    }
//    
//    private func deleteItemAction() {
//        // BenDo: complete delete implementation
//        
//        userInterface.send(.dismiss)
//    }
//    
//    private func updateAction(
//        editableValue: MarketItemEditableValue,
//        value: Any,
//        shouldDismiss: Bool
//    ) {
//        // BenDo: update DB
//        
//        DispatchQueue.main.async {
//            switch editableValue {
//            case .headline:
//                guard let text = value as? String else { return }
//                self.viewModel.item.headline = text
//                
//            case .manufacturer:
//                guard let text = value as? String else { return }
//                self.viewModel.item.manufacturer = text
//                
//            case .model:
//                guard let text = value as? String else { return }
//                self.viewModel.item.model = text
//                
//            case .plastic:
//                guard let text = value as? String else { return }
//                self.viewModel.item.plastic = text
//                
//            case .thumbImageID:
//                guard let text = value as? String else { return }
//                self.viewModel.item.thumbImageID = text
//                
//            case .price:
//                guard let value = value as? Int else { return }
//                self.viewModel.item.price = value
//                
//            case .location:
//                guard let value = value as? Location else { return }
//                self.viewModel.item.location = value
//                
//            case .itemType:
//                guard let value = value as? MarketItemType else { return }
//                self.viewModel.item.itemType = value
//                
//            case .description:
//                guard let text = value as? String else { return }
//                self.viewModel.item.description = text
//                
//            case .imageIDs:
//                guard let value = value as? [String] else { return }
//                self.viewModel.item.imageIDs = value
//            }
//        }
//        
//        if shouldDismiss {
//            userInterface.send(.dismiss)
//        }
//    }
//}
//
