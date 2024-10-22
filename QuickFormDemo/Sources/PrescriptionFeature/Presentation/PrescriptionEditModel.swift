// PrescriptionEditModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(Prescription.self)
final class PrescriptionEditModel: Validatable {
    @PropertyEditor(keyPath: \Prescription.assessments)
    var problems = MultiPickerFieldViewModel(value: [], allValues: [
        Assessment(name: "BCC", id: 1),
        Assessment(name: "SCC", id: 2)
    ], title: "Assessments")

    @PropertyEditor(keyPath: \Prescription.medication)
    var medication = MedicationBuilder(model: MedicationComponents())

    @PropertyEditor(keyPath: \Prescription.take)
    var take = FormFieldViewModel(value: Measurement<UnitDose>(value: 1, unit: .application), title: "Take:")

    @PropertyEditor(keyPath: \Prescription.frequency)
    var frequency = FormFieldViewModel(value: MedicationFrequency.predefined(schedule: .bid), title: "Frequency:")

    @PropertyEditor(keyPath: \Prescription.dispense)
    var dispense = FormattedFieldViewModel(value: .custom(1), format: .dosageForm(.capsule), title: "Quantity:")

    @PropertyEditor(keyPath: \Prescription.dispense)
    var dispensePackage = AsyncPickerFieldViewModel(
        value: Prescription.DispensePackage?.none,
        title: "",
        valuesProvider: PackageDispenseFetcher.shared.fetchDispense,
        queryBuilder: { _ in 0 }
    ).map {
        if let package = $0 {
            Prescription.Dispense.original(package)
        } else {
            Prescription.Dispense.custom(1)
        }
    } transformToSource: {
        if case let .original(package) = $0 {
            package
        } else {
            nil
        }
    }

    var info: String = ""

    @PostInit
    func configure() {
        medication.dosageForm.onValueChanged { [weak self] newValue in
            if let form = newValue?.form {
                self?.dispense.format = .dosageForm(form)
            }
        }

        addCustomValidationRule(SpyValidationRule(onValidation: { [weak self] desc in
            self?.info = desc
        }))
    }
}
