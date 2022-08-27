//
//  ItemThumbView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import SwiftUI

struct ItemThumbView: View {
    let item: MarketItemV2
    let height: CGFloat
    let width: CGFloat
    
    var thumbImage: UIImage {
        item.images.first { $0.id == item.thumbImageID }?.uiImage ?? MarketImage.defaultNoImage.uiImage
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: thumbImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width, alignment: .top)
                    .clipped()
                    .contentShape(
                        Path(CGRect(x: 0, y: 0, width: width, height: width))
                    )
                    .cornerRadius(10)
                
                Text("$\(item.price)")
                    .foregroundColor(.white)
                    .shadow(radius: 1)
                    .padding(.bottom, 4)
                    .padding(.trailing, 6)
                    .frame(width: width, height: height * 0.15, alignment: .bottomTrailing)
                    .background{
                        LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .bottom, endPoint: .top)
                    }
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
            }
            
            HStack {
                Text("\(item.headline)")
                    .font(.footnote)
                    .frame(alignment: .leading)
                    .padding(.leading, 6)
                Spacer()
            }
        }
        .frame(width: width, height: height, alignment: .top)
    }
}
