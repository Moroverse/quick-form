// FormattedFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 07:34 GMT.

import Foundation
import QuickForm
import Testing

@Suite("FormattedFieldViewModel Tests")
struct FormattedFieldViewModelTests {

    @MainActor
    @Test("Initializes with correct properties")
    func modelInit() {
        let sut = FormattedFieldViewModel(
            value: 42.5,
            format: .number,
            title: "Amount",
            placeholder: "Enter amount",
            isReadOnly: false
        )

        #expect(sut.value == 42.5)
        #expect(sut.title == "Amount")
        #expect(sut.placeholder == "Enter amount")
        #expect(sut.isReadOnly == false)
    }

    @MainActor
    @Test("Formats value according to format style")
    func valueFormatting() {
        let locale = Locale(identifier: "en_US")
        let sut = FormattedFieldViewModel(
            value: 1234.56,
            format: .currency(code: "USD").locale(locale),
            title: "Price"
        )

        let formatted = sut.format.format(sut.value)
        #expect(formatted == "$1,234.56")
    }

    @MainActor
    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let sut = FormattedFieldViewModel(
            value: 100.0,
            format: .number,
            title: "Amount"
        )

        var recordChange = 0
        var recordedValue: Double?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: Double?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(sut.value == 100.0)
        sut.value = 250.0
        #expect(recordChange == 1)
        #expect(recordedValue == 250.0)
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue == 250.0)
    }

    @MainActor
    @Test("Returns raw string value without formatting")
    func rawStringValue() {
        let sut = FormattedFieldViewModel(
            value: 1234.56,
            format: .currency(code: "USD"),
            title: "Price"
        )

        #expect(sut.rawStringValue == "1234.56")

        sut.value = 99.99
        #expect(sut.rawStringValue == "99.99")
    }

    @MainActor
    @Test("Validates model values according to validation rules")
    func validation() {
        struct LessThan20Rule: ValidationRule {
            func validate(_ value: Double?) -> ValidationResult {
                guard let value, value < 20 else {
                    return .failure("Value must be less than 20")
                }
                return .success
            }
        }

        let sut = FormattedFieldViewModel(
            value: 15.0,
            format: .number,
            validation: .of(LessThan20Rule())
        )

        #expect(sut.isValid == true)
        sut.value = 5.0
        #expect(sut.isValid == true)
        sut.value = 20.0
        #expect(sut.isValid == false)
    }

    @MainActor
    @Test("Provides proper error message when validation fails")
    func validationErrorMessage() {
        struct Rule: ValidationRule {
            static let ruleErrorMessage: LocalizedStringResource = "Any Rule Error"
            func validate(_ value: Double?) -> ValidationResult {
                guard let value, value < 20 else {
                    return .failure(Self.ruleErrorMessage)
                }
                return .success
            }
        }

        let sut = FormattedFieldViewModel(
            value: 10.0,
            format: .number,
            validation: .of(Rule())
        )

        #expect(sut.errorMessage == nil)

        sut.value = 20
        #expect(sut.errorMessage == Rule.ruleErrorMessage)
    }
}
