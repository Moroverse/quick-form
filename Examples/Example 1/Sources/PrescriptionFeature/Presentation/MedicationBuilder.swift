// MedicationBuilder.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 13:45 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(MedicationComponents.self)
final class MedicationBuilder: Validatable {
    @PropertyEditor(keyPath: \MedicationComponents.substance)
    var substance = AsyncPickerFieldViewModel(
        value: MedicationComponents.SubstancePart?.none,
        validation: .of(.required()),
        valuesProvider: SubstanceFetcher.shared.fetchSubstance,
        queryBuilder: { $0 ?? "" }
    )

    @PropertyEditor(keyPath: \MedicationComponents.route)
    var route = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationTakeRoutePart?.none,
        validation: .of(.required()),
        valuesProvider: RouteFetcher.shared.fetchRoute,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.strength)
    var strength = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationStrengthPart?.none,
        validation: .of(.required()),
        valuesProvider: StrengthFetcher.shared.fetchStrength,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.dosageForm)
    var dosageForm = AsyncPickerFieldViewModel(
        value: MedicationComponents.DosageFormPart?.none,
        validation: .of(.required()),
        valuesProvider: DosageFormFetcher.shared.fetchForm,
        queryBuilder: { _ in 0 }
    )

    @PostInit
    func configure() {
        substance.onValueChanged { [weak self] newValue in
            guard let self else { return }
            route.value = nil
            value.id = newValue?.id
        }

        route.queryBuilder = { [weak self] _ in
            self?.value.id ?? 0
        }

        route.onValueChanged { [weak self] newValue in
            guard let self else { return }
            dosageForm.value = nil
            value.id = newValue?.id
        }

        dosageForm.queryBuilder = { [weak self] _ in
            self?.value.id ?? 0
        }

        dosageForm.onValueChanged { [weak self] newValue in
            guard let self else { return }
            strength.value = nil
            value.id = newValue?.id
        }

        strength.queryBuilder = { [weak self] _ in
            self?.value.id ?? 0
        }
    }
}
