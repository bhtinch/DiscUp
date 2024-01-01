//
//  ItemDetailImagesView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import SwiftUI

struct ItemDetailImagesView: View {
    @Environment(MarketItemV2.self) private var marketItem
        
    var indexDisplayMode: PageTabViewStyle.IndexDisplayMode {
        marketItem.images.count > 1 ? .always : .never
    }
    
    var body: some View {
        TabView {
            ForEach(marketItem.images) {
                $0.itemImageView
                    .scaledToFit()
            }
//            
//            .onReceive(
//                marketItem.$images.receive(on: RunLoop.main)
//            ) { images in
//                self.images = images
//            }
        }
        .tabViewStyle(.page(indexDisplayMode: indexDisplayMode))
    }
}
