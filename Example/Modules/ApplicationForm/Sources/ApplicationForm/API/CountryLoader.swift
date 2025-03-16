// CountryLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Factory

public protocol CountryLoader {
    func loadCountries(query: String) async throws -> [String]
}

public extension Container {
    private struct Dummy: CountryLoader {
        public func loadCountries(query: String) async throws -> [String] {
            []
        }
    }

    var countryLoader: Factory<CountryLoader> {
        self {
            Dummy()
        }
    }
}

