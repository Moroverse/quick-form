//
//  Prescription.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//
import Foundation

final class Assessment: Identifiable {
    var name: String
    var id: Int

    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
}

extension Assessment: CustomStringConvertible {
    var description: String {
        name
    }
}

extension Assessment: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Assessment, rhs: Assessment) -> Bool {
        lhs.id == rhs.id
    }
}

// Mocks
enum MedicationStrength: String, Equatable {
    case m500mg = "500 mg"
    case m1000mg = "1000 mg"
    case v1ml = "1 ml"
    case v5ml = "5 ml"
}

enum DosageForm: String, Equatable {
    case tablet = "Tablet"
    case capsule = "Capsule"
    case syrup = "Syrup"
    case liquid = "Liquid"
    case injection = "Injection"
    case suppository = "Suppository"
    case other = "Other"
}

enum MedicationTakeRoute: String, Equatable {
    case oral = "Oral"
    case intravenous = "Intravenous"
    case subcutaneous = "Subcutaneous"
    case topical = "Topical"
    case other = "Other"
}

final class Medication: Identifiable {
    var id: Int
    var name: String
    var strength: MedicationStrength
    var dosageForm: DosageForm
    var route: MedicationTakeRoute

    init(id: Int, name: String, strength: MedicationStrength, dosageForm: DosageForm, route: MedicationTakeRoute) {
        self.id = id
        self.name = name
        self.strength = strength
        self.dosageForm = dosageForm
        self.route = route
    }
}

final class MedicationBuilder {
    struct SubstancePart: Identifiable, Equatable {
        let id: Int
        let substance: String
    }

    struct MedicationStrengthPart: Identifiable, Equatable {
        let id: Int
        let strength: MedicationStrength
    }

    struct DosageFormPart: Identifiable, Equatable {
        let id: Int
        let form: DosageForm
    }

    struct MedicationTakeRoutePart: Identifiable, Equatable {
        let id: Int
        let route: MedicationTakeRoute
    }

    var id: Int?
    var level: Int = 0

    var substance: SubstancePart? {
        didSet {
            if let substance {
                id = substance.id
                level = 1
            }
            route = nil
        }
    }

    var strength: MedicationStrengthPart? {
        didSet {
            if let strength {
                id = strength.id
                level = 8
            }
        }
    }

    var dosageForm: DosageFormPart? {
        didSet {
            if let dosageForm {
                id = dosageForm.id
                level = 4
            }
            strength = nil
        }
    }

    var route: MedicationTakeRoutePart? {
        didSet {
            if let route {
                id = route.id
                level = 2
            }
            dosageForm = nil
        }
    }

    func build() -> Medication? {
        guard let id, let substance, let strength, let dosageForm, let route else { return nil }
        return Medication(id: id, name: substance.substance, strength: strength.strength, dosageForm: dosageForm.form, route: route.route)
    }
}

class UnitDose: Unit {
    static let tablet = UnitDose(symbol: "tablet")
    static let capsule = UnitDose(symbol: "capsule")
    static let drop = UnitDose(symbol: "drop")
    static let application = UnitDose(symbol: "application")
}

@Observable
final class Prescription {
    var assessments: Set<Assessment>
    var medication: MedicationBuilder
    var take: Measurement<UnitDose>
    var frequency: MedicationFrequency
    var dispense: String
    var duration: Measurement<UnitDuration>
    var startDate: Date

    init(assessments: Set<Assessment>, take: Measurement<UnitDose>, frequency: MedicationFrequency, dispense: String, duration: Measurement<UnitDuration>, startDate: Date) {
        self.assessments = assessments
        medication = MedicationBuilder()
        self.take = take
        self.frequency = frequency
        self.dispense = dispense
        self.duration = duration
        self.startDate = startDate
    }
}

let fakePrescription: Prescription = .init(
    assessments: [],
    take: .init(value: 1, unit: UnitDose.tablet),
    frequency: .predefined(schedule: .BID),
    dispense: "1 tablet",
    duration: .init(value: 1, unit: .weeks),
    startDate: Date()
)
