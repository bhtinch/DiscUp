////
////  SearchHeaderView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 5/13/22.
////
//
//import SwiftUI
//
//struct SearchHeaderView: View {
//    @EnvironmentObject var viewModel: BuyViewModel
//    
//    var body: some View {
//        EmptyView()
//            .searchable(
//                text: $viewModel.searchText,
//                placement: .navigationBarDrawer(displayMode: .always),
//                prompt: Text("Discs, bags, baskets... Oh my!")
//            ) {
//                Text("use search history to populate this list").searchCompletion("driver")
//            }
//            .onSubmit(of: .search) {
//                viewModel.send(.searchSubmitted)
//            }
//    }
//}
//
//struct SearchHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchHeaderView()
//    }
//}
