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
}
