//
//  MainNavigationController.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Foundation
import UIKit

protocol NavigationControllerDelegate: UINavigationControllerDelegate {
    func controllerDidDisappear(controller: UIViewController)
    func controllerDidDisappear(controller: UINavigationController)
}

// MARK: -

class NavigationController: UINavigationController {
    private weak var customDelegate: NavigationControllerDelegate? {
        delegate as? NavigationControllerDelegate
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        customDelegate?.controllerDidDisappear(controller: self)
    }
}
