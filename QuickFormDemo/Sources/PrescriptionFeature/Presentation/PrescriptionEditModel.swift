// PrescriptionEditModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(PrescriptionComponents.self)
final class PrescriptionEditModel: Validatable {
    @PropertyEditor(keyPath: \PrescriptionComponents.assessments)
    var problems = MultiPickerFieldViewModel(value: [], allValues: [
        Assessment(name: "BCC", id: 1),
        Assessment(name: "SCC", id: 2)
    ], title: "Assessments")

    @PropertyEditor(keyPath: \PrescriptionComponents.medication)
    var medication = MedicationBuilder(value: MedicationComponents())

    @PropertyEditor(keyPath: \PrescriptionComponents.take)
    var take = FormFieldViewModel(value: Measurement<UnitDose>?.none, title: "Take:")

    @PropertyEditor(keyPath: \PrescriptionComponents.frequency)
    var frequency = FormFieldViewModel(value: MedicationFrequency?.none, title: "Frequency:")

    @PropertyEditor(keyPath: \PrescriptionComponents.dispense)
    var dispense = FormattedFieldViewModel(
        value: PrescriptionComponents.Dispense?.none,
        format: OptionalFormat(format: .dosageForm(.capsule)),
        title: "Quantity:"
    )

    @PropertyEditor(keyPath: \PrescriptionComponents.dispense)
    var dispensePackage = AsyncPickerFieldViewModel(
        value: PrescriptionComponents.DispensePackage?.none,
        title: "",
        valuesProvider: PackageDispenseFetcher.shared.fetchDispense,
        queryBuilder: { _ in 0 }
    ).map {
        if let package = $0 {
            PrescriptionComponents.Dispense.original(package)
        } else {
            PrescriptionComponents.Dispense?.none
        }
    } transformToSource: {
        if case let .original(package) = $0 {
            package
        } else {
            nil
        }
    }

    @PropertyEditor(keyPath: Never)
    var info: String = ""

    @PostInit
    func configure() {
        medication.dosageForm.onValueChanged { [weak self] newValue in
            if let form = newValue?.form {
                self?.dispense.format = OptionalFormat(format: .dosageForm(form))
            }
        }

        dispensePackage.onValueChanged { [weak self] newValue in
            self?.dispense.value = newValue
        }

        addCustomValidationRule(SpyValidationRule(onValidation: { [weak self] desc in
            self?.info = desc
        }))
    }
}
