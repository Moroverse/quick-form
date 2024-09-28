// Medication.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-28 10:04 GMT.

final class Medication: Identifiable {
    var id: Int
    var name: String
    var strength: MedicationStrength
    var dosageForm: DosageForm
    var route: MedicationTakeRoute

    init(id: Int, name: String, strength: MedicationStrength, dosageForm: DosageForm, route: MedicationTakeRoute) {
        self.id = id
        self.name = name
        self.strength = strength
        self.dosageForm = dosageForm
        self.route = route
    }
}

// Mocks
enum MedicationStrength: String, Equatable {
    case m500mg = "500 mg"
    case m1000mg = "1000 mg"
    case v1ml = "1 ml"
    case v5ml = "5 ml"
}

enum DosageForm: String, Equatable {
    case tablet = "Tablet"
    case capsule = "Capsule"
    case syrup = "Syrup"
    case liquid = "Liquid"
    case injection = "Injection"
    case suppository = "Suppository"
    case other = "Other"
}

enum MedicationTakeRoute: String, Equatable {
    case oral = "Oral"
    case intravenous = "Intravenous"
    case subcutaneous = "Subcutaneous"
    case topical = "Topical"
    case other = "Other"
}
