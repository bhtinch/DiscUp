//
//  ViewModel.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Combine
import CoreData

/// Base class for all view models
class ViewModel<Output>: NSObject, ObservableObject, Identifiable, Publisher {
    typealias Failure = Never

    private let action = PassthroughSubject<Output, Failure>()

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
