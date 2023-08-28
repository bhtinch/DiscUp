//
//  SellNewPageTabView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 6/15/22.
//

import SwiftUI

struct SellNewPageTabView: View {
    @EnvironmentObject var newItemViewModel: SellNewItemViewModel
    
    var body: some View {
        TabView(selection: $newItemViewModel.pageIndex) {
            SellNewDetailsPageView().tag(0)
            SellNewPhotosPageView().tag(1)
            SellNewPreviewPageView(marketItem: $newItemViewModel.item).tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
