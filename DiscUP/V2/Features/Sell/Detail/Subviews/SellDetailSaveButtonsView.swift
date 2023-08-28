//
//  SellDetailSaveButtonsView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 3/21/22.
//

import SwiftUI

struct SellDetailSaveButtonsView: View {
    @EnvironmentObject var viewModel: SellDetailViewModel
    
    @State private var showingDeleteAlert: Bool = false
    @State private var showingBackAlert: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.white)
            .tint(.init(red: 0.8, green: 0.3, blue: 0.3))
            .shadow(radius: 2)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Button {
                    guard viewModel.hasChanges else { return
                        viewModel.send(.dismiss(save: false)) }
                    
                    showingBackAlert = true
                    
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.white)
                .tint(!viewModel.hasChanges ? .blue : .yellow)
                .shadow(radius: 2)
                
                Button {
                    viewModel.send(.dismiss(save: true))
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .shadow(radius: 2)
                .disabled(!viewModel.hasChanges)
            }
        }
        .padding([.top, .trailing, .leading])
        
        .alert("Are you sure you want to permanently delete this item?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.send(.deleteItem)
            }
        }
        
        .alert("You have unsaved changes.", isPresented: $showingBackAlert) {
            Button("Discard Changes", role: .destructive) {
                viewModel.send(.dismiss(save: false))
            }
            
            Button("Save Changes") {
                viewModel.send(.dismiss(save: true))
            }
        }
    }
}

struct SellDetailSaveButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        SellDetailSaveButtonsView()
    }
}
