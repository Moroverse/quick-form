// MedicationBuilder.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-22 05:56 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(MedicationComponents.self)
final class MedicationBuilder: Validatable {
    @PropertyEditor(keyPath: \MedicationComponents.substance)
    var substance = AsyncPickerFieldViewModel(value: MedicationComponents.SubstancePart?.none, valuesProvider: SubstanceFetcher.shared.fetchSubstance, queryBuilder: { $0 })

    @PropertyEditor(keyPath: \MedicationComponents.route)
    var route = AsyncPickerFieldViewModel(value: MedicationComponents.MedicationTakeRoutePart?.none, valuesProvider: RouteFetcher.shared.fetchRoute, queryBuilder: { _ in 0 })

    @PostInit
    func configure() {
        substance.onValueChanged { [weak self] newValue in
            self?.route.value = nil
            self?.model.id = newValue?.id
        }

        route.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }
    }
}
