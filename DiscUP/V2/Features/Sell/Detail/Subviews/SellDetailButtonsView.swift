////
////  SellDetailButtonsView.swift
////  DiscUpV2
////
////  Created by Ben Tincher on 3/15/22.
////
//
//import SwiftUI
//
//struct SellDetailButtonsView: View {
//    @EnvironmentObject var viewModel: SellDetailViewModel
//    
//    @State private var showingDetailsPopover: Bool = false
//    
//    var body: some View {
//        HStack {
//            Spacer()
//            
//            ForEach(SellEditOption.allCases, id: \.self) { option in
//                Button {
//                    handleButtonAction(option: option)
//                } label: {
//                    HStack {
//                        option.buttonIcon
//                        Text(option.buttonTitle)
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(Color(uiColor: AppTheme.Colors.mainAccent.uiColor))
//            }
//            
//            Spacer()
//        }
//        
//        .popover(isPresented: $showingDetailsPopover) {
//            SellEditDetailsView(isPresented: $showingDetailsPopover)
//        }
//    }
//}
//
//// MARK: - Button Actions
//
//extension SellDetailButtonsView {
//    private func handleButtonAction(option: SellEditOption) {
//        switch option {
//        case .details:  detailsButtonTapped()
//        case .images:   imagesButtonTapped()
//        }
//    }
//    
//    private func detailsButtonTapped() { showingDetailsPopover.toggle() }
//    
//    private func imagesButtonTapped() { viewModel.send(.editPhotosTapped($viewModel.item)) }
//}
