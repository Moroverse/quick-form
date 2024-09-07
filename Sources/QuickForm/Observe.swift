// Observe.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation

public func observe(apply: @escaping @Sendable () -> Void) {
    onChange(apply: apply)
}

func onChange(apply: @escaping @Sendable () -> Void) {
    withObservationTracking {
        apply()
    } onChange: {
        Task { @MainActor in
            onChange(apply: apply)
        }
    }
}
