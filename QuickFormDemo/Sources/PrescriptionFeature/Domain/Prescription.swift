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

final class Prescription: AutoDebugStringConvertible {
    struct DispensePackage: Identifiable, Equatable {
        let id: Int
        let description: String
    }

    enum Dispense: CustomStringConvertible, Equatable {
        case custom(Int)
        case original(DispensePackage)

        var description: String {
            switch self {
            case let .custom(int):
                String(int)
            case let .original(package):
                package.description
            }
        }
    }

    var assessments: Set<Assessment>
    var medication: Medication?
    var take: Measurement<UnitDose>
    var frequency: MedicationFrequency
    var dispense: Dispense
    var duration: Measurement<UnitDuration>
    var startDate: Date

    init(
        assessments: Set<Assessment>,
        medication: Medication,
        take: Measurement<UnitDose>,
        frequency: MedicationFrequency,
        dispense: Dispense,
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
    dispense: .custom(1),
    duration: .init(value: 1, unit: .weeks),
    startDate: Date()
)

