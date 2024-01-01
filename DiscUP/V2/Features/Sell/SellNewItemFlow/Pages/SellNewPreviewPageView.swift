//
//  SellNewPreviewPageView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/17/22.
//

import SwiftUI

struct SellNewPreviewPageView: View {
    @State var marketItem: MarketItemV2
    
    var body: some View {
        GeometryReader { geo in
            let constraint =
            UIDevice.current.orientation.isLandscape ?
            geo.size.height :
            geo.size.width
            
            ScrollView {
                VStack {
                    ItemDetailImagesView()
                        .frame(width: constraint, height: constraint, alignment: .top)
                        .clipped()
                        .contentShape(
                            Path(CGRect(x: 0, y: 0, width: constraint, height: constraint))
                        )
                    
                    VStack(alignment: .leading) {
                        SellDetailHeadlineView()
                        
                        SellDetailDescriptionView(width: geo.size.width * 0.95)
                    }
                    .frame(width: geo.size.width * 0.95, alignment: .leading)
                }
                .environment(marketItem)
            }
        }
    }
}
