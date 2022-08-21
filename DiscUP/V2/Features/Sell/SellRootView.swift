////
////  SellRootView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 2/9/22.
////
//
//import SwiftUI
//
//struct SellRootView: View {
//    
//    // MARK: - Properties
//    
//    @ObservedObject var viewModel: SellViewModel
//    
//    // this property not necessary but can be useful to automatically get the state of searching
//    @Environment(\.isSearching)
//    private var isSearching: Bool
//    
//    @State private var showingNewItemsPopover: Bool = false
//    
//    // MARK: - Body
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("My Items")
//                    .font(.title2).bold()
//                    .foregroundColor(.white)
//                    .shadow(radius: 2)
//                    .padding(.leading, 8)
//                
//                Spacer()
//                
//                Button {
//                    viewModel.send(.createNew)
//                } label: {
//                    HStack {
//                        Image(systemName: "plus.circle.fill")
//                        Text("Add New")
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(.white)
//                .foregroundColor(Color(uiColor: AppTheme.Colors.mainAccent.uiColor))
//            }
//            .padding(10)
//            .background(Color(uiColor: AppTheme.Colors.mainAccent.uiColor))
//            
//            ItemsCollectionView(
//                items: $viewModel.items,
//                itemSelected: $viewModel.selectedItem
//            )
//            
//            .navigationBarHidden(true)
//            
//            .searchable(
//                text: $viewModel.searchText,
//                prompt: Text("Search your items for sale...")
//            ) {
//                Text("use search history to populate this list").searchCompletion("driver")
//            }
//            .onSubmit(of: .search) {
//                viewModel.send(.searchSubmitted)
//            }
//        }
//    }
//}
