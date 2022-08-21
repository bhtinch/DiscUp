//
//  BaseView.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Combine
import UIKit

// MARK: - Base View

class BaseView: UIView {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base Stack View

class BaseStackView: UIStackView {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base Table View

class BaseTableView: UITableView {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        tableFooterView = UIView()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base Collection View

class BaseCollectionView: UICollectionView {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base Label

class BaseLabel: UILabel {
    
    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base ImageView

class BaseImageView: UIImageView {
    
    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}
