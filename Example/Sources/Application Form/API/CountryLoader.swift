// CountryLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:10 GMT.

public protocol CountryLoader {
    func loadCountries(query: String) async throws -> [String]
}
