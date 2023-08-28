//
//  ItemsCollectionView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import Combine
import SwiftUI

struct ItemsCollectionView: View {
    @Binding var items: [MarketItemV2]
    @Binding var itemSelected: MarketItemV2
        
    var body: some View {
        GeometryReader { geo in
            let constraint =
            UIDevice.current.orientation.isLandscape ?
            geo.size.height :
            geo.size.width
            
            let columnWidth = constraint * 0.46
            
            let columnCount: Int = {
                guard columnWidth != 0 else { return 2 }
                
                return Int(geo.size.width/columnWidth)
            }()
            
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: .init(.flexible(minimum: 0, maximum: 300)),
                        count: columnCount
                    ),
                    spacing: 0
                ) {
                    ForEach(items, id: \.self) { item in
                        ItemThumbView(
                            item: item,
                            height: columnWidth + 40,
                            width: columnWidth
                        )
                        .onTapGesture {
                            itemSelected = item
                        }
                    }
                }
                .padding([.top, .bottom], constraint * 0.02)
            }
            .padding([.leading, .trailing], constraint * 0.02)
        }
    }
}
