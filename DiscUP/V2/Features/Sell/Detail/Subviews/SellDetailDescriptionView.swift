//
//  SellDetailDescriptionView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/22/22.
//

import SwiftUI

struct SellDetailDescriptionView: View {
    @Binding var item: MarketItemV2
    
    let width: Double
        
    init(marketItem: Binding<MarketItemV2>, width: Double) {
        self._item = marketItem
        self.width = width
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(item.description)
                    .frame(width: width, alignment: .leading)
            }
        }
        .border(.tertiary, width: 1)
        .clipped()
    }
}
