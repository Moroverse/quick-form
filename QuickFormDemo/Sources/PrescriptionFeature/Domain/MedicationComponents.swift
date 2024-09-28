// MedicationComponents.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-28 10:04 GMT.

final class MedicationComponents {
    struct SubstancePart: Identifiable, Equatable {
        let id: Int
        let substance: String
    }

    struct MedicationStrengthPart: Identifiable, Equatable {
        let id: Int
        let strength: MedicationStrength
    }

    struct DosageFormPart: Identifiable, Equatable {
        let id: Int
        let form: DosageForm
    }

    struct MedicationTakeRoutePart: Identifiable, Equatable {
        let id: Int
        let route: MedicationTakeRoute
    }

    var id: Int?
    var level: Int = 0

    var substance: SubstancePart?
    var strength: MedicationStrengthPart?
    var dosageForm: DosageFormPart?
    var route: MedicationTakeRoutePart?

    func build() -> Medication? {
        guard let id, let substance, let strength, let dosageForm, let route else { return nil }
        return Medication(
            id: id,
            name: substance.substance,
            strength: strength.strength,
            dosageForm: dosageForm.form,
            route: route.route
        )
    }
}
