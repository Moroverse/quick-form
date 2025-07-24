// StateLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import FactoryKit

public protocol StateLoader {
    func loadStates(country: String) async throws -> [String]
    func hasStates(country: String) async -> Bool
}

public extension Container {
    struct DummyStateLoader: StateLoader {
        public func loadStates(country: String) async throws -> [String] {
            []
        }

        public func hasStates(country: String) async -> Bool {
            false
        }
    }

    var stateLoader: Factory<StateLoader> {
        self {
            DummyStateLoader()
        }
    }
}
