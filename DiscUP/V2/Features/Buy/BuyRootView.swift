//
//  HomeView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 1/16/22.
//

import Combine
import SwiftUI

struct BuyRootView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: BuyViewModel
    
    // this property not necessary but can be useful to automatically get the state of searching
    @Environment(\.isSearching)
    private var isSearching: Bool
    
    @State var searchText: String = ""
    
    // MARK: - Body
    
    var body: some View {
        ItemsCollectionView(
            items: $viewModel.items,
            itemSelected: $viewModel.selectedItem
        )
        .environmentObject(viewModel)
        
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Discs, bags, baskets... Oh my!")
        ) {
            Text("use search history to populate this list").searchCompletion("driver")
        }
        .onSubmit(of: .search) {
            viewModel.send(.searchSubmitted)
        }
    }
}
