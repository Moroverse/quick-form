// Subscription.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:17 GMT.

/// A token representing an active subscription to an event stream.
///
/// A `Subscription` represents the connection between a subscriber and an event publisher.
/// When you subscribe to events through a ``Dispatcher``, you receive a `Subscription` object
/// that allows you to manage the lifecycle of that subscription.
///
/// When a subscription is no longer needed, call ``unsubscribe()`` to stop receiving events
/// and prevent memory leaks by releasing any resources associated with the subscription.
///
/// ## Example
///
/// ```swift
/// // Subscribe to an event
/// let subscription = dispatcher.subscribe { (event: UserLoggedInEvent) in
///     print("User logged in: \(event.userId)")
/// }
///
/// // Later, when no longer interested in these events
/// subscription.unsubscribe()
/// ```
///
/// Each subscription is specific to a particular event type and handler. If you subscribe
/// to multiple event types, you'll receive a separate `Subscription` object for each one.
///
/// - SeeAlso: ``Dispatcher``
public protocol Subscription {
    /// Cancels this subscription, preventing any further events from being delivered.
    ///
    /// After calling this method:
    /// - The subscriber will no longer receive notifications for this event type
    /// - Resources associated with the subscription will be released
    /// - The dispatcher will remove the subscription from its internal registry
    ///
    /// It is safe to call this method multiple times, though only the first call will have an effect.
    /// It's a good practice to call `unsubscribe()` when you're done with a subscription to prevent
    /// memory leaks, especially for long-lived objects.
    func unsubscribe()
}
