// CountryLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import Factory

public protocol CountryLoader {
    func loadCountries(query: String) async throws -> [String]
}

public extension Container {
    struct DummyCountryLoader: CountryLoader {
        public func loadCountries(query: String) async throws -> [String] {
            []
        }
    }

    var countryLoader: Factory<CountryLoader> {
        self {
            DummyCountryLoader()
        }
    }
}
