// Fetchers.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-22 04:54 GMT.

final class SubstanceFetcher {
    static let shared = SubstanceFetcher()

    func fetchSubstance(query: String) async throws -> [MedicationComponents.SubstancePart] {
        try await Task.sleep(for: .seconds(2))
        return [
            .init(id: 1, substance: "Aspirin"),
            .init(id: 2, substance: "Ibuprofen"),
            .init(id: 3, substance: "Botox")
        ]
    }
}

final class RouteFetcher {
    static let shared = RouteFetcher()

    func fetchRoute(substanceID id: Int) async throws -> [MedicationComponents.MedicationTakeRoutePart] {
        try await Task.sleep(for: .seconds(2))
        return [
            .init(id: 4, route: .oral),
            .init(id: 5, route: .intravenous),
            .init(id: 7, route: .topical)
        ]
    }
}

final class DosageFormFetcher {
    static let shared = DosageFormFetcher()

    func fetchForm(routeID id: Int) async throws -> [MedicationComponents.DosageFormPart] {
        try await Task.sleep(for: .seconds(2))
        return [
            .init(id: 12, form: .capsule),
            .init(id: 13, form: .tablet),
            .init(id: 14, form: .drops),
            .init(id: 15, form: .suspension)
        ]
    }
}

final class StrengthFetcher {
    static let shared = StrengthFetcher()

    func fetchStrength(dosageID id: Int) async throws -> [MedicationComponents.MedicationStrengthPart] {
        try await Task.sleep(for: .seconds(2))
        return [
            .init(id: 8, strength: .m200mg),
            .init(id: 9, strength: .m400mg),
            .init(id: 10, strength: .m600mg),
            .init(id: 11, strength: .m800mg)
        ]
    }
}

final class PackageDispenseFetcher {
    static let shared = PackageDispenseFetcher()

    func fetchDispense(medicationID id: Int) async throws -> [PrescriptionComponents.DispensePackage] {
        try await Task.sleep(for: .seconds(2))
        return [
            .init(id: 16, description: "1"),
            .init(id: 17, description: "6"),
            .init(id: 18, description: "10"),
            .init(id: 19, description: "16"),
            .init(id: 20, description: "20")
        ]
    }
}
