// AsyncPickerFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 09:11 GMT.

import Foundation
import QuickForm
import Testing

private struct TestItem: Identifiable {
    let id: Int
    let name: String
}

@Suite("AsyncPickerFieldViewModel Tests")
struct AsyncPickerFieldViewModelTests {
    @Test("Initializes with correct properties")
    func modelInit() {
        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            title: "Test Picker",
            placeholder: "Select an item",
            isReadOnly: true,
            validation: nil,
            valuesProvider: { _ in [] },
            queryBuilder: { $0 ?? "" }
        )

        #expect(sut.value == nil)
        #expect(sut.title == "Test Picker")
        #expect(sut.placeholder == "Select an item")
        #expect(sut.isReadOnly == true)

        if case .initial = sut.allValues {
            // Expected initial state
        } else {
            Issue.record("Expected initial state but got \(sut.allValues)")
        }
    }

    @Test("Defaults to empty title, nil placeholder, and non-read-only state")
    func defaultParameters() {
        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            valuesProvider: { _ in [] },
            queryBuilder: { $0 ?? "" }
        )

        #expect(sut.title == "")
        #expect(sut.placeholder == nil)
        #expect(sut.isReadOnly == false)
    }

    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let item1 = TestItem(id: 1, name: "Item 1")
        let item2 = TestItem(id: 2, name: "Item 2")

        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            valuesProvider: { _ in [] },
            queryBuilder: { $0 ?? "" }
        )

        var recordChange = 0
        var recordedValue: TestItem?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: TestItem?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(sut.value == nil)

        // Update to non-nil value
        sut.value = item1
        #expect(recordChange == 1)
        #expect(recordedValue?.id == 1)
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue?.id == 1)

        // Update to different non-nil value
        sut.value = item2
        #expect(recordChange == 2)
        #expect(recordedValue?.id == 2)
        #expect(secondRecordChange == 2)
        #expect(secondRecordedValue?.id == 2)

        // Update to nil
        sut.value = nil
        #expect(recordChange == 3)
        #expect(recordedValue == nil)
        #expect(secondRecordChange == 3)
        #expect(secondRecordedValue == nil)
    }

    @Test("Validates value according to validation rules")
    func validation() {
        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            validation: .of(.required()),
            valuesProvider: { _ in [] },
            queryBuilder: { $0 ?? "" }
        )

        // Initially invalid (nil)
        #expect(!sut.isValid)
        #expect(sut.errorMessage == "This field is required")

        // Set to non-nil - should be valid
        sut.value = TestItem(id: 1, name: "Test Item")
        #expect(sut.isValid)
        #expect(sut.errorMessage == nil)

        // Set back to nil - should be invalid
        sut.value = nil
        #expect(!sut.isValid)
        #expect(sut.errorMessage == "This field is required")
    }

    @Test("Search function updates allValues state")
    @MainActor
    func searchFunction() async {
        let searchableItems = [
            "": [
                TestItem(id: 1, name: "Apple"),
                TestItem(id: 2, name: "Banana"),
                TestItem(id: 3, name: "Cherry")
            ],
            "ba": [
                TestItem(id: 2, name: "Banana")
            ]
        ]

        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            valuesProvider: {
                searchableItems[$0] ?? []
            },
            queryBuilder: { $0 ?? "" }
        )

        // Initially in .initial state
        if case .initial = sut.allValues {
            // This is expected
        } else {
            Issue.record("Expected .initial state but got \(sut.allValues)")
        }

        // Search with empty query
        await sut.search("")

        if case let .loaded(loadedItems) = sut.allValues {
            #expect(loadedItems.count == 3)
        } else {
            Issue.record("Expected .loaded state but got \(sut.allValues)")
        }

        // Search with specific query
        await sut.search("ba")

        if case let .loaded(loadedItems) = sut.allValues {
            #expect(loadedItems.count == 1)
            #expect(loadedItems.first?.name == "Banana")
        } else {
            Issue.record("Expected .loaded state but got \(sut.allValues)")
        }
    }

    @Test("Search handles errors correctly")
    @MainActor
    func searchError() async {
        struct TestError: Error {}

        let sut = AsyncPickerFieldViewModel<[TestItem], String>(
            value: nil,
            valuesProvider: { _ in
                throw TestError()
            },
            queryBuilder: { $0 ?? "" }
        )

        await sut.search("test")

        if case .error = sut.allValues {
            // This is expected
        } else {
            Issue.record("Expected .error state but got \(sut.allValues)")
        }
    }
}
