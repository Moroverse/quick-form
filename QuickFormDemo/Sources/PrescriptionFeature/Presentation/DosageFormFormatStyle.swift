// DosageFormFormatStyle.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-28 18:07 GMT.

import Foundation

struct DosageFormFormatStyle: ParseableFormatStyle {
    typealias FormatInput = Prescription.Dispense
    typealias FormatOutput = String

    private var dosageForm: String

    func format(_ input: FormatInput) -> String {
        "\(input) \(dosageForm)"
    }

    var parseStrategy: DosageFormParseStrategy { DosageFormParseStrategy() }

    init(dosageForm: DosageForm) {
        self.dosageForm = dosageForm.rawValue
    }

    func dosageForm(_ dosageForm: DosageForm) -> Self {
        var selfCopy = self
        selfCopy.dosageForm = dosageForm.rawValue
        return selfCopy
    }
}

struct DosageFormParseStrategy: ParseStrategy {
    func parse(_ value: String) throws -> Prescription.Dispense {
        let components = value.components(separatedBy: " ")
        let dosage: Int
        switch components.count {
        case 1:
            if let result = Int(value) {
                dosage = result
            } else {
                throw ParseError.invalidFormat
            }

        case 2:
            if let result = Int(components[0]) {
                dosage = result
            } else {
                throw ParseError.invalidFormat
            }

        default:
            throw ParseError.invalidFormat
        }

        return .custom(dosage)
    }

    enum ParseError: Error {
        case invalidFormat
        case unknownDosageForm
    }
}

extension FormatStyle where Self == DosageFormFormatStyle {
    static func dosageForm(_ dosageForm: DosageForm) -> DosageFormFormatStyle { .init(dosageForm: dosageForm) }
}
