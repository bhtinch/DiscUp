//
//  BaseTableViewCell.swift
//  intel
//
//  Created by Ben Tincher on 11/10/21.
//

import Combine
import UIKit

// MARK: - Base Table View Cell

class BaseTableViewCell: UITableViewCell {

    // MARK: -

    static var reuseIdentifier: String { String(describing: Self.self) }

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}

// MARK: - Base Collection View Cell

public class BaseCollectionViewCell: UICollectionViewCell {

    // MARK: - Static

    static var reuseIdentifier: String { String(describing: Self.self) }

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
    }
}
