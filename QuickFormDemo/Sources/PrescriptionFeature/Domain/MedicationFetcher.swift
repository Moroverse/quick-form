//
//  MedicationFetcher.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 18.9.24..
//

struct MedicationInfo: Identifiable {
    let name: String
    let id: Int
}

final class MedicationFetcher {
    static let shared = MedicationFetcher()
    
    func fetchMedication(query: String) async throws-> [MedicationInfo] {
        return [.init(name: "Medication 1", id: 1), .init(name: "Medication 2", id: 2)]
    }
}
