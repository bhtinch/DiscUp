//
//  SellDetailDescriptionView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/22/22.
//

import SwiftUI

struct SellDetailDescriptionView: View {
    @Environment(MarketItemV2.self) private var item
    
    let width: Double
        
    init(width: Double) {
        self.width = width
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(item.description ?? "Please add a description...")
                    .frame(width: width, alignment: .leading)
            }
        }
        .border(.tertiary, width: 1)
        .clipped()
    }
}
