// Prescription.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

//
//  Prescription.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//
import Foundation

final class PrescriptionComponents: AutoDebugStringConvertible {
    struct DispensePackage: Identifiable, Equatable, AutoDebugStringConvertible {
        let id: Int
        let description: String
    }

    enum Dispense: CustomStringConvertible, Equatable, AutoDebugStringConvertible {
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
    var medication: MedicationComponents
    var take: Measurement<UnitDose>?
    var frequency: MedicationFrequency?
    var dispense: Dispense?
    var duration: Measurement<UnitDuration>?
    var startDate: Date?
    var messageToPharmacist: String?

    init(
        assessments: Set<Assessment>,
        medication: MedicationComponents,
        take: Measurement<UnitDose>?,
        frequency: MedicationFrequency?,
        dispense: Dispense?,
        duration: Measurement<UnitDuration>?,
        startDate: Date?,
        messageToPharmacist: String? = nil
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

let fakePrescription: PrescriptionComponents = .init(
    assessments: [],
    medication: MedicationComponents(
        id: 4,
        substance: .init(id: 1, substance: "Aspirin"),
        strength: .init(id: 2, strength: .m1000mg),
        dosageForm: .init(id: 3, form: .capsule),
        route: .init(id: 4, route: .intravenous)
    ),
    take: .init(value: 1, unit: UnitDose.tablet),
    frequency: .predefined(schedule: .bid),
    dispense: .custom(1),
    duration: .init(value: 1, unit: .weeks),
    startDate: Date()
)
