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

final class StrengthFetcher {
    static let shared = StrengthFetcher()

    func fetchStrength(dosageID id: Int) async throws -> [MedicationComponents.MedicationStrengthPart] {
        [
            .init(id: 8, strength: .m1000mg),
            .init(id: 9, strength: .m500mg),
            .init(id: 10, strength: .v1ml),
            .init(id: 11, strength: .v5ml)
        ]
    }
}

final class DosageFormFetcher {
    static let shared = DosageFormFetcher()

    func fetchForm(routeID id: Int) async throws -> [MedicationComponents.DosageFormPart] {
        [
            .init(id: 12, form: .capsule),
            .init(id: 13, form: .injection),
            .init(id: 14, form: .liquid),
            .init(id: 15, form: .suppository)
        ]
    }
}
