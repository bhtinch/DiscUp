//
//  BuyDetailImagesView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/7/22.
//

import SwiftUI

// Bendo: Can delete if no longer needed

//struct BuyDetailImagesView: View {
//
//    @EnvironmentObject var viewModel: BuyDetailViewModel
//
//    var imageIDs: [String] {
//        var imageIDs = [String]()
//
//        imageIDs.append(viewModel.item.thumbImageID)
//
//        viewModel.item.imageIDs.forEach { imageIDs.append($0) }
//
//        return imageIDs
//    }
//
//    var indexDisplayMode: PageTabViewStyle.IndexDisplayMode {
//        viewModel.item.imageIDs.isEmpty ? .never : .always
//    }
//
//    var body: some View {
//        TabView {
//            ForEach(imageIDs, id: \.self) {
//                Image($0)
//                    .resizable()
//                    .scaledToFill()
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: indexDisplayMode))
//    }
//}
