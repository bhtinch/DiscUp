////
////  SellfEditDetailsView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 4/13/22.
////
//
//import SwiftUI
//
//struct SellEditDetailsView: View {
//    
//    @EnvironmentObject var viewModel: SellDetailViewModel
//    
//    @Binding var isPresented: Bool
//    
//    @State private var initialItemState: MarketItem?
//        
//    init(isPresented: Binding<Bool>) {
//        _isPresented = isPresented
//    }
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            HStack(alignment: .bottom) {
//                Button("Cancel") {
//                    resetItem()
//                    isPresented = false
//                }
//                
//                Spacer()
//                
//                Text("Edit Details")
//                    .font(.title2)
//                
//                Spacer()
//                
//                Button("Save") {
//                    print("save details")
//                    isPresented = false
//                }
//            }
//            .padding([.leading, .trailing], 20)
//            
//            EditItemDetailsView(marketItem: $viewModel.item)
//        }
//        .onAppear() {
//            initialItemState = viewModel.item
//        }
//    }
//}
//
////  MARK: - Private Methods
//
//extension SellEditDetailsView {
//    private func resetItem() {
//        guard let initialItem = initialItemState else { return }
//        
//        viewModel.item.headline = initialItem.headline
//        viewModel.item.location = initialItem.location
//        viewModel.item.itemType = initialItem.itemType
//        viewModel.item.price = initialItem.price
//        viewModel.item.manufacturer = initialItem.manufacturer
//        viewModel.item.model = initialItem.model
//        viewModel.item.plastic = initialItem.plastic
//        viewModel.item.description = initialItem.description
//    }
//}
