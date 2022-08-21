////
////  BuyDetailRootView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 3/6/22.
////
//
//import Foundation
//import SwiftUI
//
//struct BuyDetailRootView: View {
//    
//    // MARK: - Properties
//    
//    @ObservedObject var viewModel: BuyDetailViewModel
//    
//    var item: MarketItem {
//        viewModel.item
//    }
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
//                    ItemDetailImagesView(marketItem: $viewModel.item)
//                        .frame(width: constraint, height: constraint, alignment: .top)
//                        .clipped()
//                        .contentShape(
//                            Path(CGRect(x: 0, y: 0, width: constraint, height: constraint))
//                        )
//                    
//                    VStack(alignment: .leading) {
//                        BuyDetailHeadlineView()
//                        
//                        Button {
//                            // present messaging
//                        } label: {
//                            Spacer()
//                            Text("Message Seller")
//                            Spacer()
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .frame(width: geo.size.width * 0.95, alignment: .center)
//                        
//                        ScrollView {
//                            VStack {
//                                Text(item.description)
//                                    .frame(width: geo.size.width * 0.95, alignment: .leading)
//                            }
//                        }
//                        .border(.tertiary, width: 1)
//                        .clipped()
//                    }
//                    .frame(width: geo.size.width * 0.95, alignment: .leading)
//                }
//            }
//        }
//        .environmentObject(viewModel)
//    }
//}
//
//struct BuyDetailRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuyDetailRootView(viewModel: BuyDetailViewModel(item: MarketItem.items.first!))
//    }
//}
