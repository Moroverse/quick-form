// PickerFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 08:08 GMT.

import Foundation
import QuickForm
import Testing

enum TestEnum: String, Hashable, CustomStringConvertible, CaseIterable {
    case option1
    case option2
    case option3

    var description: String {
        switch self {
        case .option1: "Option 1"
        case .option2: "Option 2"
        case .option3: "Option 3"
        }
    }
}

@Suite("PickerFieldViewModel Tests")
struct PickerFieldViewModelTests {
    @Test("Initializes with correct properties")
    func modelInit() {
        let allValues = TestEnum.allCases
        let sut = PickerFieldViewModel(
            value: TestEnum.option2,
            allValues: allValues,
            title: "Test Picker",
            isReadOnly: true
        )

        #expect(sut.value == .option2)
        #expect(sut.allValues.count == 3)
        #expect(sut.allValues[0] == .option1)
        #expect(sut.allValues[1] == .option2)
        #expect(sut.allValues[2] == .option3)
        #expect(sut.title == "Test Picker")
        #expect(sut.isReadOnly == true)
    }

    @Test("Defaults to empty title and non-read-only state")
    func defaultParameters() {
        let sut = PickerFieldViewModel(
            value: TestEnum.option1,
            allValues: [.option1]
        )

        #expect(sut.title == "")
        #expect(sut.isReadOnly == false)
    }

    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let sut = PickerFieldViewModel(
            value: TestEnum.option1,
            allValues: [.option1, .option2, .option3]
        )

        var recordChange = 0
        var recordedValue: TestEnum?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: TestEnum?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(sut.value == .option1)
        sut.value = .option2
        #expect(recordChange == 1)
        #expect(recordedValue == .option2)
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue == .option2)

        // Second update
        sut.value = .option3
        #expect(recordChange == 2)
        #expect(recordedValue == .option3)
        #expect(secondRecordChange == 2)
        #expect(secondRecordedValue == .option3)
    }
}
