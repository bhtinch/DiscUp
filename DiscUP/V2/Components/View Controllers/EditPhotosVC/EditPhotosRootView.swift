//
//  EditPhotosRootView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 4/24/22.
//

import SwiftUI

struct EditPhotosRootView: View {
    @ObservedObject var viewModel: EditPhotosViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button("Cancel") {
                    viewModel.send(.cancel)
                }
                
                Spacer()
                
                Text("Edit Photos")
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.mainAccent.color)
                    .bold()
                
                Spacer()
                
                Button("Save") {
                    viewModel.send(.save)
                }
            }
            .padding([.leading, .trailing, .top], 20)
            
            Divider()
            
            EditPhotosView(images: $viewModel.item.images)
        }
    }
}
