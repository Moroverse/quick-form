// StateLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import Factory

public protocol StateLoader {
    func loadStates(country: String) async throws -> [String]
    func hasStates(country: String) async -> Bool
}

public extension Container {
    private struct Dummy: StateLoader {
        func loadStates(country: String) async throws -> [String] {
            []
        }

        func hasStates(country: String) async -> Bool {
            false
        }
    }

    var stateLoader: Factory<StateLoader> {
        self {
            Dummy()
        }
    }
}
