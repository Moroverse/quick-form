// Subscription.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:24 GMT.

public protocol Subscription {
    /// Unsubscribes from the event, stopping further notifications.
    func unsubscribe()
}
