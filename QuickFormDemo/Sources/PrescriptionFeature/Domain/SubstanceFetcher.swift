//
//  SubstanceFetcher.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 18.9.24..
//

final class SubstanceFetcher {
    static let shared = SubstanceFetcher()
    
    func fetchSubstance(query: String) async throws-> [MedicationBuilder.SubstancePart] {
        return [
            .init(id: 1, substance: "Aspirin"),
            .init(id: 2, substance: "Ibuprofen"),
            .init(id: 3, substance: "Botox")
        ]
    }
}

final class RouteFetcher {
    static let shared = RouteFetcher()
    
    func fetchRoute(substanceID id: Int) async throws-> [MedicationBuilder.MedicationTakeRoutePart] {
        return [
            .init(id: 4, route: .oral),
            .init(id: 5, route: .intravenous),
            .init(id: 6, route: .intravenous),
            .init(id: 7, route: .topical)
        ]
    }
}
