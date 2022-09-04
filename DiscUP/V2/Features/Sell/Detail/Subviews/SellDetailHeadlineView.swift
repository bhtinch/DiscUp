//
//  SellDetailHeadlineView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/15/22.
//

import SwiftUI

struct SellDetailHeadlineView: View {
    @Binding var item: MarketItemV2
        
    init(marketItem: Binding<MarketItemV2>) {
        self._item = marketItem
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.headline)
                    .font(.title)
                
                Text("$\(item.price) - \(item.location.city), \(item.location.state) \(item.location.zipCode)")
                
                Text("Listed 1 day ago")
            }
            
            Spacer()
            
            VStack {
                Image(uiImage: item.seller.avatarImage?.uiImage ?? UIImage(systemName: "person") ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .clipped()
                    .shadow(radius: 2)
                
                Text(item.seller.displayName ?? "Unknown Seller")
                    .font(.footnote)
            }
        }
    }
}
