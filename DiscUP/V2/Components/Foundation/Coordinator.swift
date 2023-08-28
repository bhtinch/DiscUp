//
//  Coordinator.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Combine
import CoreData

/// Base class for all coordinators
class Coordinator<Output>: NSObject, ObservableObject, Identifiable, Publisher {
    typealias Failure = Never

    private let action = PassthroughSubject<Output, Failure>()

    var cancellables: Set<AnyCancellable> = []

    lazy var dispatchQueue: DispatchQueue = {
        DispatchQueue(label: "com.BenjaminTincher.DiscUpV2.coordinator.\(Self.self)", qos: .userInitiated)
    }()

    // MARK: -

    override init() {}

    // MARK: -
    public func send(_ input: Output) {
        action.send(input)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        action.subscribe(subscriber)
    }

    deinit {
        debugPrint("deinit: \(Self.self)")
    }
}
