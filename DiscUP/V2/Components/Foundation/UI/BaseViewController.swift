//
//  BaseViewController.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Combine
import UIKit

// MARK: -  Base View Controller

/// Base controller for UIKit views
class BaseViewController: UIViewController {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()
    let spinner: SpinnerView

    // MARK: -

    init() {
        spinner = SpinnerView()
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: -  Base List View Controller

/// Base table view controller for UIKit views
class BaseListViewController: UITableViewController {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()
    let spinner: SpinnerView

    // MARK: - Initialization

    override init(style: UITableView.Style = .plain) {
        spinner = SpinnerView()
        
        super.init(style: style)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: -  Base Tab Bar Controller

/// Base tab bar view controller for UIKit views
class BaseTabBarController: UITabBarController {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: -

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: -  Base Collection View Controller

class BaseCollectionViewController: UICollectionViewController {

    // MARK: -

    var cancellables = Set<AnyCancellable>()

    // MARK: -

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}
