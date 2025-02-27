// Dispatcher.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:24 GMT.

import Foundation

private struct ConcreteSubscription: Subscription {
    private let _unsubscribe: () -> Void

    init(unsubscribe: @escaping () -> Void) {
        _unsubscribe = unsubscribe
    }

    public func unsubscribe() {
        _unsubscribe()
    }
}

public class Dispatcher {
    private protocol AnyHandler {}
    private struct TypedHandler<T>: AnyHandler {
        let id: UUID
        let handler: (T) -> Void
    }

    private var registrations: [AnyHandler]

    public init() {
        registrations = []
    }

    public func publish<T>(_ event: T) {
        for typedHandler in registrations {
            if let typedHandler = typedHandler as? TypedHandler<T> {
                typedHandler.handler(event)
            }
        }
    }

    public func subscribe<T>(handler: @escaping @Sendable (T) -> Void) -> Subscription {
        let key = UUID()

        let typedHandler = TypedHandler(id: key, handler: handler)

        registrations.append(typedHandler)

        return ConcreteSubscription { [weak self] in
            if let index = self?.registrations.firstIndex(where: {
                if let typedHandler = $0 as? TypedHandler<T>,
                   typedHandler.id == key {
                    true
                } else {
                    false
                }
            }) {
                self?.registrations.remove(at: index)
            }
        }
    }
}
