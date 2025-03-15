// StateLoader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:10 GMT.

public protocol StateLoader {
    func loadStates(country: String) async throws -> [String]
    func hasStates(country: String) async -> Bool
}
