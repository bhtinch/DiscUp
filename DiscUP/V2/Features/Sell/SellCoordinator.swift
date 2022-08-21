////
////  SellCoordinator.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 2/9/22.
////
//
//import Foundation
//import Combine
//
//// MARK: - ViewController
//
//class SellViewModel: ViewModel<SellCoordinator.Action> {
//    @Published var items: [MarketItem] = {
//        var arr = Array(MarketItem.items.prefix(3))
//        
//        arr.append(contentsOf: MarketItem.goodItems.prefix(2))
//        
//        return arr
//    }()
//    
//    @Published var searchText: String = ""
//    
//    @Published var selectedItem: MarketItem = MarketItem.defaultNoItem {
//        didSet {
//            send(.itemSelected(selectedItem))
//        }
//    }
//}
//
//// MARK: - Coordinator
//
//class SellCoordinator: Coordinator<SellCoordinator.Action> {
//    
//    // MARK: - Actions
//    
//    enum UIAction {
//        case goToDetail(MarketItem)
//        case presentNewItemVC
//    }
//    
//    // MARK: - UIActions
//    
//    enum Action {
//        case searchSubmitted
//        case createNew
//        case itemSelected(MarketItem)
//    }
//    
//    // MARK: - Properties
//    
//    let userInterface = PassthroughSubject<UIAction, Never>()
//    let viewModel: SellViewModel
//    
//    // MARK: - Initialization
//    
//    override init() {
//        viewModel = SellViewModel()
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
//extension SellCoordinator {
//    private func perform(action: Action) {
//        switch action {
//        case .searchSubmitted:
//            searchSubmittedAction()
//            
//        case .createNew:
//            createNewAction()
//            
//        case .itemSelected(let item):
//            userInterface.send(.goToDetail(item))
//        }
//    }
//    
//    private func searchSubmittedAction() {
//        guard !viewModel.searchText.isEmpty else { return }
//        
//        debugPrint(viewModel.searchText)
//        // FB search and return values
//        // update items on viewModel
//    }
//    
//    private func createNewAction() {
//        userInterface.send(.presentNewItemVC)
//    }
//}
//
