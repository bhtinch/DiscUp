////
////  SellDetailViewController.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 3/15/22.
////
//
//import Foundation
//
//class SellDetailViewController: BaseHostingController <SellDetailRootView> {
//    
//    // MARK: - Private
//    let coordinator: SellDetailCoordinator
//    
//    // MARK: - Initialization
//    
//    init(item: MarketItem) {
//        coordinator = SellDetailCoordinator(item: item)
//        
//        let homeView = SellDetailRootView(viewModel: coordinator.viewModel)
//        
//        super.init(rootView: homeView)
//        
//        coordinator
//            .userInterface
//            .receive(on: RunLoop.main)
//            .sink { [weak self] in
//                self?.perform(action: $0)
//            }
//            .store(in: &cancellables)
//        
//        setUp()
//    }
//}
//
//// MARK: - Action Methods
//
//extension SellDetailViewController {
//    private func perform(action: SellDetailCoordinator.UIAction) {
//        switch action {
//        case .presentEditPhotos(let item):
//            let vc = EditPhotosViewController(item: item)
//            present(vc, animated: true)
//            
//        case .dismiss:
//            dismiss(animated: true)
//        }
//    }
//}
//
//// MARK: - Set Up
//
//extension SellDetailViewController {
//    private func setUp() {
//        modalPresentationStyle = .fullScreen
//    }
//}
