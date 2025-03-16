// FormCollectionViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 09:49 GMT.

import Foundation
import QuickForm
import Testing

@Suite("FormCollectionViewModel Tests")
struct FormCollectionViewModelTests {
    struct TestItem: Identifiable, Sendable, Equatable {
        let id = UUID()
        var name: String
        var value: Int
    }

    @Test("Initializes with correct properties")
    func modelInit() {
        let items = [
            TestItem(name: "Item 1", value: 10),
            TestItem(name: "Item 2", value: 20)
        ]

        let sut = FormCollectionViewModel<TestItem>(
            value: items,
            title: "Test Items",
            insertionTitle: "Add Item",
            isReadOnly: true
        )

        #expect(sut.value.count == 2)
        #expect(sut.value[0].name == "Item 1")
        #expect(sut.value[1].name == "Item 2")
        #expect(sut.title == "Test Items")
        #expect(sut.insertionTitle == "Add Item")
        #expect(sut.isReadOnly == true)
    }

    @Test("Defaults to empty title, default insertion title, and non-read-only state")
    func defaultParameters() {
        let sut = FormCollectionViewModel<TestItem>(
            value: []
        )

        #expect(sut.title == "")
        #expect(sut.insertionTitle == "Add")
        #expect(sut.isReadOnly == false)
    }

    @Test("canDelete message onCanDelete")
    func deleteWithCanDelete() {
        let items = [
            TestItem(name: "Item 1", value: 10),
            TestItem(name: "Item 2", value: 20),
            TestItem(name: "Item 3", value: 30)
        ]

        let sut = FormCollectionViewModel<TestItem>(
            value: items
        )

        var onCanDeleteCallsCount = 0
        sut.onCanDelete = { _ in
            onCanDeleteCallsCount += 1
            return false
        }

        let offset = IndexSet(integer: 0)
        #expect(sut.canDelete(at: offset) == false)
        #expect(onCanDeleteCallsCount == 1)
        #expect(sut.value.count == 3)

        sut.onCanDelete = { _ in
            onCanDeleteCallsCount += 1
            return true
        }

        #expect(sut.canDelete(at: offset))
        #expect(onCanDeleteCallsCount == 2)
        sut.delete(at: offset)
        #expect(sut.value.count == 2)
    }

    @Test("Insertion behavior with async provider")
    @MainActor
    func insertWithProvider() async {
        let sut = FormCollectionViewModel<TestItem>(
            value: [],
            title: "Test Items"
        )

        sut.onInsert {
            TestItem(name: "Inserted Item", value: 42)
        }

        #expect(sut.value.isEmpty)

        // Test insertion
        await sut.insert()
        #expect(sut.value.count == 1)
        #expect(sut.value[0].name == "Inserted Item")
        #expect(sut.value[0].value == 42)

        // Test insertion again
        await sut.insert()
        #expect(sut.value.count == 2)
    }

    @Test("Selection behavior with canSelect")
    func selectionBehavior() async {
        let items = [
            TestItem(name: "Item 1", value: 10),
            TestItem(name: "Item 2", value: 20),
            TestItem(name: "Item 3", value: 30)
        ]

        let sut = FormCollectionViewModel<TestItem>(
            value: items
        )

        sut.onCanSelect = { item in
            item.value > 15
        }
        var selectedItem: TestItem?
        sut.onSelect { item in
            selectedItem = item
            return item
        }

        let oldSelection = items[2]
        selectedItem = oldSelection
        #expect(!sut.canSelect(item: items[0]))
        await sut.select(item: items[0])
        #expect(selectedItem == oldSelection)

        selectedItem = nil
        #expect(sut.canSelect(item: items[1]))
        await sut.select(item: items[1])
        #expect(selectedItem == items[1])

        selectedItem = oldSelection
        await sut.select(item: nil)
        #expect(selectedItem == oldSelection)
    }

    @Test("Move behavior with canMove")
    func moveWithCanMove() {
        let items = [
            TestItem(name: "Item 1", value: 10),
            TestItem(name: "Item 2", value: 20),
            TestItem(name: "Item 3", value: 30)
        ]

        let sut = FormCollectionViewModel<TestItem>(
            value: items
        )

        sut.onCanMove = { source, _ in
            source.contains(0)
        }

        let validSource = IndexSet(integer: 0)
        #expect(sut.canMove(from: validSource, to: 2))
        sut.move(from: validSource, to: 2)
        #expect(sut.value[1].name == "Item 1")

        let invalidSource = IndexSet(integer: 2)
        #expect(!sut.canMove(from: invalidSource, to: 0))
    }

    @Test("Track collection changes with onChange")
    func trackChanges() {
        let sut = FormCollectionViewModel<TestItem>(
            value: []
        )

        var changeCallCount = 0
        var lastDifference: CollectionDifference<TestItem>?

        sut.onChange { difference in
            changeCallCount += 1
            lastDifference = difference
        }

        let newItem = TestItem(name: "New Item", value: 50)
        sut.value.append(newItem)

        #expect(changeCallCount == 1)
        #expect(lastDifference == .init([.insert(offset: 0, element: newItem, associatedWith: nil)]))

        sut.value.removeLast()

        #expect(changeCallCount == 2)
        #expect(lastDifference == .init([.remove(offset: 0, element: newItem, associatedWith: nil)]))
    }
}
