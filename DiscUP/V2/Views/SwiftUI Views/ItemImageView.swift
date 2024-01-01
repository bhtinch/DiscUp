//
//  ItemImageView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 12/22/23.
//

import SwiftUI
import Kingfisher

struct ItemImageView: View {
    var imageURL: URL?
    
    var body: some View {
        KFImage(imageURL)
            .onFailureImage(UIImage(named: "logo2") ?? UIImage())
            .resizable()
            .scaledToFill()
    }
}

struct AvatarImageView: View {
    var imageURL: URL?
    
    var body: some View {
        KFImage(imageURL)
            .onFailureImage(UIImage(systemName: "person") ?? UIImage())
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    ItemImageView()
}
