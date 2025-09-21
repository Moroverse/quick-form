// OptionalPickerFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 08:21 GMT.

import Foundation
import QuickForm
import Testing

enum TestOption: String, Hashable, CustomStringConvertible {
    case first
    case second
    case third

    var description: String {
        switch self {
        case .first: "First Option"
        case .second: "Second Option"
        case .third: "Third Option"
        }
    }
}

@Suite("OptionalPickerFieldViewModel Tests")
struct OptionalPickerFieldViewModelTests {

    @MainActor
    @Test("Initializes with correct properties")
    func modelInit() {
        let allValues: [TestOption] = [.first, .second, .third]
        let sut = OptionalPickerFieldViewModel(
            value: TestOption.second,
            allValues: allValues,
            title: "Test Picker",
            placeholder: "Select an option",
            isReadOnly: true,
            validation: nil
        )

        #expect(sut.value == .second)
        #expect(sut.allValues.count == 3)
        #expect(sut.allValues[0] == .first)
        #expect(sut.allValues[1] == .second)
        #expect(sut.allValues[2] == .third)
        #expect(sut.title == "Test Picker")
        #expect(sut.placeholder == "Select an option")
        #expect(sut.isReadOnly == true)
    }

    @MainActor
    @Test("Initializes with nil value")
    func modelInitWithNil() {
        let allValues: [TestOption] = [.first, .second, .third]
        let sut = OptionalPickerFieldViewModel<TestOption>(
            value: nil,
            allValues: allValues,
            title: "Test Picker"
        )

        #expect(sut.value == nil)
        #expect(sut.allValues.count == 3)
    }

    @MainActor
    @Test("Defaults to empty title, nil placeholder, and non-read-only state")
    func defaultParameters() {
        let sut = OptionalPickerFieldViewModel(
            value: TestOption.first,
            allValues: [.first]
        )

        #expect(sut.title == "")
        #expect(sut.placeholder == nil)
        #expect(sut.isReadOnly == false)
    }

    @MainActor
    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let sut = OptionalPickerFieldViewModel(
            value: TestOption.first,
            allValues: [.first, .second, .third]
        )

        var recordChange = 0
        var recordedValue: TestOption?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: TestOption?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(sut.value == .first)

        // Update to different value
        sut.value = .second
        #expect(recordChange == 1)
        #expect(recordedValue == .second)
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue == .second)

        // Update to nil
        sut.value = nil
        #expect(recordChange == 2)
        #expect(recordedValue == nil)
        #expect(secondRecordChange == 2)
        #expect(secondRecordedValue == nil)

        // Update to non-nil again
        sut.value = .third
        #expect(recordChange == 3)
        #expect(recordedValue == .third)
        #expect(secondRecordChange == 3)
        #expect(secondRecordedValue == .third)
    }

    @MainActor
    @Test("Validates value according to validation rules")
    func validation() {
        let sut = OptionalPickerFieldViewModel(
            value: TestOption.first,
            allValues: [.first, .second, .third],
            validation: .of(RequiredRule())
        )

        // Initially valid
        #expect(sut.isValid)
        #expect(sut.errorMessage == nil)

        // Set to nil - should fail validation
        sut.value = nil
        #expect(!sut.isValid)
        #expect(sut.errorMessage == "This field is required")

        // Set back to non-nil - should pass validation
        sut.value = .third
        #expect(sut.isValid)
        #expect(sut.errorMessage == nil)
    }

    @MainActor
    @Test("Handles no validation rules properly")
    func noValidation() {
        let sut = OptionalPickerFieldViewModel<TestOption>(
            value: nil,
            allValues: [.first, .second]
        )

        // With no validation, nil should be valid
        #expect(sut.isValid)
        #expect(sut.errorMessage == nil)

        sut.value = .first
        #expect(sut.isValid)
        #expect(sut.errorMessage == nil)
    }
}
