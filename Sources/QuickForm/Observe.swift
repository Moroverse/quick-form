// Observe.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation

public func observe(apply: @escaping @Sendable () -> Void) {
    func observeAndReapply() {
        withObservationTracking {
            apply()
        } onChange: {
            Task { @MainActor in
                observeAndReapply()
            }
        }
    }
    observeAndReapply()
}

public func isEqual<A: Equatable>(_ lhs: A, _ rhs: some Equatable) -> Bool {
    if let rhs = rhs as? A, lhs == lhs {
        return true
    }

    return false
}
