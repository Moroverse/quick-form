// Dispatcher.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:17 GMT.

import Foundation

private struct ConcreteSubscription: Subscription {
    private let _unsubscribe: () -> Void

    init(unsubscribe: @escaping () -> Void) {
        _unsubscribe = unsubscribe
    }

    func unsubscribe() {
        _unsubscribe()
    }
}

/// A type-safe event dispatcher that enables publish-subscribe communication between components.
///
/// `Dispatcher` provides a decoupled way for components to communicate through events.
/// Publishers can dispatch events of any type, and subscribers can listen for events of specific types.
///
/// ## Features
/// - Type-safe event publishing and subscription
/// - Memory-safe subscription management (prevents retain cycles)
/// - Support for multiple subscribers for the same event type
///
/// ## Example
///
/// ```swift
/// // Create a dispatcher
/// let dispatcher = Dispatcher()
///
/// // Define an event type
/// struct UserLoggedInEvent {
///     let userId: String
///     let timestamp: Date
/// }
///
/// // Subscribe to events
/// let subscription = dispatcher.subscribe { (event: UserLoggedInEvent) in
///     print("User \(event.userId) logged in at \(event.timestamp)")
/// }
///
/// // Publish an event
/// dispatcher.publish(UserLoggedInEvent(userId: "user123", timestamp: Date()))
///
/// // Later, when no longer needed
/// subscription.unsubscribe()
/// ```
public class Dispatcher {
    private protocol AnyHandler {}
    private struct TypedHandler<T>: AnyHandler {
        let id: UUID
        let handler: (T) -> Void
    }

    private var registrations: [AnyHandler]

    /// Creates a new, empty dispatcher.
    public init() {
        registrations = []
    }

    /// Publishes an event to all subscribers of the matching type.
    ///
    /// This method delivers the event to all registered handlers that match the event's type.
    /// If there are no matching subscribers, this method has no effect.
    ///
    /// - Parameter event: The event to publish to subscribers.
    ///
    /// - Note: Event delivery happens synchronously on the calling thread.
    public func publish<T>(_ event: T) {
        for typedHandler in registrations {
            if let typedHandler = typedHandler as? TypedHandler<T> {
                typedHandler.handler(event)
            }
        }
    }

    /// Registers a handler to receive events of a specific type.
    ///
    /// This method creates a subscription that will invoke the provided handler
    /// whenever an event of matching type is published through this dispatcher.
    ///
    /// - Parameter handler: A closure that will be called with events of type `T`.
    ///   The handler is marked as `@Sendable` to ensure thread safety.
    ///
    /// - Returns: A `Subscription` object that can be used to cancel this subscription.
    ///
    /// - Note: The dispatcher holds a weak reference to `self` in the returned subscription
    ///   to avoid retain cycles.
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
