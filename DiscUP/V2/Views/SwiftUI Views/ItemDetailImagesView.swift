//
//  ItemDetailImagesView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import SwiftUI

struct ItemDetailImagesView: View {
    @Binding var marketItem: MarketItemV2
    
    @State var images: [MarketImage] = [MarketImage.defaultNoImage]
        
    init(marketItem: Binding<MarketItemV2>) {
        self._marketItem = marketItem
    }
        
    var indexDisplayMode: PageTabViewStyle.IndexDisplayMode {
        images.count > 1 ? .always : .never
    }
    
    var body: some View {
        TabView {
            ForEach(images) {
                Image(uiImage: $0.uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
            .onReceive(
                marketItem.$images.receive(on: RunLoop.main)
            ) { images in
                self.images = images
            }
        }
        .tabViewStyle(.page(indexDisplayMode: indexDisplayMode))
        
        .onAppear {
            images = marketItem.images
        }
    }
}
