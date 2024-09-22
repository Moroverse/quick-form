// SubstanceFetcher.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-22 04:54 GMT.

final class SubstanceFetcher {
    static let shared = SubstanceFetcher()

    func fetchSubstance(query: String) async throws -> [MedicationComponents.SubstancePart] {
        [
            .init(id: 1, substance: "Aspirin"),
            .init(id: 2, substance: "Ibuprofen"),
            .init(id: 3, substance: "Botox")
        ]
    }
}

final class RouteFetcher {
    static let shared = RouteFetcher()

    func fetchRoute(substanceID id: Int) async throws -> [MedicationComponents.MedicationTakeRoutePart] {
        [
            .init(id: 4, route: .oral),
            .init(id: 5, route: .intravenous),
            .init(id: 6, route: .intravenous),
            .init(id: 7, route: .topical)
        ]
    }
}
