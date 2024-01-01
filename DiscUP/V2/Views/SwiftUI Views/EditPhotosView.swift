//
//  EditPhotosView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import SwiftUI
import Foundation

struct EditPhotosView: View {
    @Environment(MarketItemV2.self) var item
    
    @State private var showingImagePicker = false
    @State private var imageSelected: UIImage?
    
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
            
            VStack {
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: .init(.flexible(minimum: 0, maximum: 300)),
                            count: columnCount
                        ),
                        spacing: 10
                    ) {
                        ForEach(item.images) { image in
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.secondary)
                                
                                Image(uiImage: UIImage(data: image.imageData ?? Data()) ?? UIImage(systemName: "person")!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: columnWidth,
                                        height: columnWidth,
                                        alignment: .top
                                    )
                                    .cornerRadius(8)
                                    .padding(2)
                                    .onTapGesture {}
                                
                                HStack {
                                    Button() {
                                        let _ = item.images.removeAll { $0.id == image.id }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.init(red: 0.8, green: 0.3, blue: 0.3))
                                    .shadow(radius: 2)
                                    .padding([.top, .leading], 4)
                                    
                                    Spacer()
                                    
                                    Button() {
                                        item.thumbImageID = image.id
                                    } label: {
                                        Image(systemName: "photo.on.rectangle")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(
                                        item.thumbImageID == image.id ? .green : .gray
                                    )
                                    .shadow(radius: 2)
                                    .padding([.top, .leading, .trailing], 4)
                                }
                            }
                        }
                    }
                }
                
                Button() {
                    showingImagePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: constraint * 0.15, height: constraint * 0.15, alignment: .center)
                        .foregroundColor(Color(AppTheme.Colors.mainAccent.uiColor))
                }
                .shadow(radius: 2)
            }
            .padding(constraint * 0.02)
        }
        
        .onChange(of: imageSelected) { _ in
            guard let imageSelected = imageSelected else { return }
            
            // bendo: set temporary uid... uid will be set later in save function with respect to userID, itemID, imageID
            let uid = UUID().uuidString
            
            item.images.append(
                MarketImage(uid: uid, imageData: imageSelected.pngData())
            )
        }
        
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $imageSelected)
        }
    }
}
