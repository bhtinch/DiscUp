//
//  BaseHostingController.swift
//  OnboardingFeatureApp
//
//  Created by Yas Tabasam on 6/29/21.
//

import Combine
import SwiftUI

class BaseHostingController<RootView: SwiftUI.View>: UIHostingController<RootView> {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: -

    override init(rootView: RootView) {
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}
