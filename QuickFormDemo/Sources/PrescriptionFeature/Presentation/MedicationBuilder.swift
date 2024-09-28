// MedicationBuilder.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-22 05:56 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(MedicationComponents.self)
final class MedicationBuilder: Validatable {
    @PropertyEditor(keyPath: \MedicationComponents.substance)
    var substance = AsyncPickerFieldViewModel(
        value: MedicationComponents.SubstancePart?.none,
        valuesProvider: SubstanceFetcher.shared.fetchSubstance,
        queryBuilder: { $0 ?? "" }
    )

    @PropertyEditor(keyPath: \MedicationComponents.route)
    var route = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationTakeRoutePart?.none,
        valuesProvider: RouteFetcher.shared.fetchRoute,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.strength)
    var strength = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationStrengthPart?.none,
        valuesProvider: StrengthFetcher.shared.fetchStrength,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.dosageForm)
    var dosageForm = AsyncPickerFieldViewModel(
        value: MedicationComponents.DosageFormPart?.none,
        valuesProvider: DosageFormFetcher.shared.fetchForm,
        queryBuilder: { _ in 0 }
    )

    @PostInit
    func configure() {
        substance.onValueChanged { [weak self] newValue in
            self?.route.value = nil
            self?.model.id = newValue?.id
        }

        route.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }

        route.onValueChanged { [weak self] newValue in
            self?.dosageForm.value = nil
            self?.model.id = newValue?.id
        }

        dosageForm.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }

        dosageForm.onValueChanged { [weak self] newValue in
            self?.strength.value = nil
            self?.model.id = newValue?.id
        }

        strength.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }
    }
}

extension MedicationBuilder: ValueEditor {
    var value: Medication? {
        get {
            model.build()
        }
        set(newValue) {
            if let substance = newValue?.name {
                model.substance = MedicationComponents.SubstancePart(id: newValue!.id, substance: substance)
            }

            if let route = newValue?.route {
                model.route = MedicationComponents.MedicationTakeRoutePart(id: newValue!.id, route: route)
            }

            if let form = newValue?.dosageForm {
                model.dosageForm = MedicationComponents.DosageFormPart(id: newValue!.id, form: form)
            }

            if let strength = newValue?.strength {
                model.strength = MedicationComponents.MedicationStrengthPart(id: newValue!.id, strength: strength)
            }
        }
    }
}
