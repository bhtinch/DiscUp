//
//  BuyDetailHeadlineView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/7/22.
//

import SwiftUI
import Kingfisher

struct BuyDetailHeadlineView: View {
    
    @EnvironmentObject var viewModel: BuyDetailViewModel
    
    var item: MarketItemV2 {
        viewModel.item
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
                item.seller.avatarImage.imageView
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
