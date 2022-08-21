//
//  MessagesRootView.swift
//  DiscUpV2
//
//  Created by Ben Tincher on 2/9/22.
//

import SwiftUI

struct MessagesRootView: View {
    
    // MARK: - Properties
    
    let viewModel: MessagesViewModel
    
    // MARK: - Body
    
    var body: some View {
        Text("Messages Root View")
    }
}

struct MessagesRootView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesRootView(viewModel: MessagesViewModel())
    }
}
