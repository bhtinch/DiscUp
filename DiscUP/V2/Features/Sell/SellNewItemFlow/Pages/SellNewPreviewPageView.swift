//
//  SellNewPreviewPageView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/17/22.
//

import SwiftUI

struct SellNewPreviewPageView: View {
    @Binding var marketItem: MarketItemV2
        
    init(marketItem: Binding<MarketItemV2>) {
        self._marketItem = marketItem
    }
    
    var body: some View {
        GeometryReader { geo in
            let constraint =
            UIDevice.current.orientation.isLandscape ?
            geo.size.height :
            geo.size.width
            
            ScrollView {
                VStack {
                    ItemDetailImagesView(marketItem: $marketItem)
                        .frame(width: constraint, height: constraint, alignment: .top)
                        .clipped()
                        .contentShape(
                            Path(CGRect(x: 0, y: 0, width: constraint, height: constraint))
                        )
                    
                    VStack(alignment: .leading) {
                        SellDetailHeadlineView(marketItem: $marketItem)
                        
                        SellDetailDescriptionView(marketItem: $marketItem, width: geo.size.width * 0.95)
                    }
                    .frame(width: geo.size.width * 0.95, alignment: .leading)
                }
            }
        }
    }
}
