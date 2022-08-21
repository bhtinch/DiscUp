////
////  SellDetailRootView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 3/15/22.
////
//
//import Foundation
//import SwiftUI
//
//struct SellDetailRootView: View {
//    
//    // MARK: - Properties
//    
//    @ObservedObject var viewModel: SellDetailViewModel
//    
//    // MARK: - Body
//    
//    var body: some View {
//        GeometryReader { geo in
//            let constraint =
//            UIDevice.current.orientation.isLandscape ?
//            geo.size.height :
//            geo.size.width
//            
//            ScrollView {
//                VStack {
//                    ZStack(alignment: .topTrailing) {
//                        ItemDetailImagesView(marketItem: $viewModel.item)
//                            .frame(width: constraint, height: constraint, alignment: .top)
//                            .clipped()
//                            .contentShape(
//                                Path(CGRect(x: 0, y: 0, width: constraint, height: constraint))
//                            )
//                        
//                        SellDetailSaveButtonsView()
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        SellDetailHeadlineView(marketItem: $viewModel.item)
//                        
//                        SellDetailButtonsView()
//                        
//                        SellDetailDescriptionView(marketItem: $viewModel.item, width: geo.size.width * 0.95)
//                    }
//                    .frame(width: geo.size.width * 0.95, alignment: .leading)
//                }
//            }
//        }
//        .environmentObject(viewModel)
//    }
//}
//
//struct SellDetailRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        SellDetailRootView(viewModel: SellDetailViewModel(item: MarketItem.items.first!))
//    }
//}
