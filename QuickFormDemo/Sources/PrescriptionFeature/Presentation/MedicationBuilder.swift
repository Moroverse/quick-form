// MedicationBuilder.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-22 05:56 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(MedicationComponents.self)
final class MedicationBuilder: Validatable {
    private let dispatcher = Dispatcher()

    @PropertyEditor(keyPath: \MedicationComponents.substance)
    var substance = AsyncPickerFieldViewModel(
        value: MedicationComponents.SubstancePart?.none,
        validation: .of(RequiredRule()),
        valuesProvider: SubstanceFetcher.shared.fetchSubstance,
        queryBuilder: { $0 ?? "" }
    )

    @PropertyEditor(keyPath: \MedicationComponents.route)
    var route = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationTakeRoutePart?.none,
        validation: .of(RequiredRule()),
        valuesProvider: RouteFetcher.shared.fetchRoute,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.strength)
    var strength = AsyncPickerFieldViewModel(
        value: MedicationComponents.MedicationStrengthPart?.none,
        validation: .of(RequiredRule()),
        valuesProvider: StrengthFetcher.shared.fetchStrength,
        queryBuilder: { _ in 0 }
    )

    @PropertyEditor(keyPath: \MedicationComponents.dosageForm)
    var dosageForm = AsyncPickerFieldViewModel(
        value: MedicationComponents.DosageFormPart?.none,
        validation: .of(RequiredRule()),
        valuesProvider: DosageFormFetcher.shared.fetchForm,
        queryBuilder: { _ in 0 }
    )

    @PostInit
    func configure() {
        substance.onValueChanged { [weak self] newValue in
            guard let self else { return }
            route.value = nil
            model.id = newValue?.id
            dispatcher.publish(model)
        }

        route.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }

        route.onValueChanged { [weak self] newValue in
            guard let self else { return }
            dosageForm.value = nil
            model.id = newValue?.id
            dispatcher.publish(model)
        }

        dosageForm.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }

        dosageForm.onValueChanged { [weak self] newValue in
            guard let self else { return }
            strength.value = nil
            model.id = newValue?.id
            dispatcher.publish(model)
        }

        strength.queryBuilder = { [weak self] _ in
            self?.model.id ?? 0
        }

        strength.onValueChanged { [weak self] _ in
            guard let self else { return }
            dispatcher.publish(model)
        }
    }
}

extension MedicationBuilder: ObservableValueEditor {
    func onValueChanged(_ change: @escaping (MedicationComponents) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }

    var value: MedicationComponents {
        get {
            model
        }
        set(newValue) {
            model = newValue
            update()
        }
    }
}
