//
//  SellNewPhotosPageView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/17/22.
//

import SwiftUI

struct SellNewPhotosPageView: View {
    @EnvironmentObject var viewModel: SellNewItemViewModel
        
    var body: some View {
        EditPhotosView()
            .environment(viewModel.item)
    }
}

struct SellNewPhotosPageView_Previews: PreviewProvider {
    static var previews: some View {
        SellNewPhotosPageView()
    }
}
