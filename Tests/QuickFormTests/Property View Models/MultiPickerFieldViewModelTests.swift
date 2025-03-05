// MultiPickerFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 08:15 GMT.

import Foundation
import QuickForm
import Testing

enum TestCategory: String, Hashable, CustomStringConvertible {
    case food
    case travel
    case entertainment
    case sports
    case education

    var description: String {
        switch self {
        case .food: "Food"
        case .travel: "Travel"
        case .entertainment: "Entertainment"
        case .sports: "Sports"
        case .education: "Education"
        }
    }
}

@Suite("MultiPickerFieldViewModel Tests")
struct MultiPickerFieldViewModelTests {
    @Test("Initializes with correct properties")
    func modelInit() {
        let initialSelection: Set<TestCategory> = [.food, .travel]
        let allValues: [TestCategory] = [.food, .travel, .entertainment, .sports]
        let sut = MultiPickerFieldViewModel(
            value: initialSelection,
            allValues: allValues,
            title: "Categories",
            isReadOnly: true
        )

        #expect(sut.value.count == 2)
        #expect(sut.value.contains(.food))
        #expect(sut.value.contains(.travel))
        #expect(sut.allValues.count == 4)
        #expect(sut.title == "Categories")
        #expect(sut.isReadOnly == true)
    }

    @Test("Defaults to empty title and non-read-only state")
    func defaultParameters() {
        let sut = MultiPickerFieldViewModel(
            value: [TestCategory.food],
            allValues: [.food, .travel]
        )

        #expect(sut.title == "")
        #expect(sut.isReadOnly == false)
    }

    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let sut = MultiPickerFieldViewModel(
            value: [TestCategory.food],
            allValues: [.food, .travel, .entertainment]
        )

        var recordChange = 0
        var recordedValue: Set<TestCategory>?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: Set<TestCategory>?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(recordChange == 0)
        #expect(secondRecordChange == 0)

        // First update
        sut.value = [.food, .travel]
        #expect(recordChange == 1)
        #expect(recordedValue?.count == 2)
        #expect((recordedValue?.contains(.food)) != nil)
        #expect(recordedValue?.contains(.travel) != nil)
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue?.count == 2)

        // Second update
        sut.value = [.entertainment]
        #expect(recordChange == 2)
        #expect(recordedValue?.count == 1)
        #expect(recordedValue?.contains(.entertainment) != nil)
        #expect(secondRecordChange == 2)
        #expect(secondRecordedValue?.count == 1)
        #expect(secondRecordedValue?.contains(.entertainment) != nil)

        // Clear selection
        sut.value = []
        #expect(recordChange == 3)
        #expect(recordedValue?.isEmpty == true)
        #expect(secondRecordChange == 3)
        #expect(secondRecordedValue?.isEmpty == true)
    }
}
