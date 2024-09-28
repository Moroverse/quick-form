// Prescription.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

//
//  Prescription.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//
import Foundation

final class Prescription {
    var assessments: Set<Assessment>
    var medication: Medication?
    var take: Measurement<UnitDose>
    var frequency: MedicationFrequency
    var dispense: Int
    var duration: Measurement<UnitDuration>
    var startDate: Date

    init(
        assessments: Set<Assessment>,
        medication: Medication,
        take: Measurement<UnitDose>,
        frequency: MedicationFrequency,
        dispense: Int,
        duration: Measurement<UnitDuration>,
        startDate: Date
    ) {
        self.assessments = assessments
        self.medication = medication
        self.take = take
        self.frequency = frequency
        self.dispense = dispense
        self.duration = duration
        self.startDate = startDate
    }
}

let fakePrescription: Prescription = .init(
    assessments: [],
    medication: Medication(id: 1, name: "Aspirin", strength: .m1000mg, dosageForm: .capsule, route: .intravenous),
    take: .init(value: 1, unit: UnitDose.tablet),
    frequency: .predefined(schedule: .bid),
    dispense: 1,
    duration: .init(value: 1, unit: .weeks),
    startDate: Date()
)
