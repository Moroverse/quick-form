//
//  FormCollectionViewModelTests.swift
//  quick-form
//
//  Created by Daniel Moro on 3.3.25..
//

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
            return TestItem(name: "Inserted Item", value: 42)
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

//    @Test("Selection behavior with canSelect")
//    func selectionBehavior() {
//        let items = [
//            TestItem(name: "Item 1", value: 10),
//            TestItem(name: "Item 2", value: 20),
//            TestItem(name: "Item 3", value: 30)
//        ]
//
//        let sut = FormCollectionViewModel<TestItem>(
//            value: items
//        )
//
//        var selectedItem: TestItem?
//
//        // Configure selection behavior
//        sut.configure { vm in
//            // Only allow selecting items with value > 15
//            vm.onCanSelect { item in
//                return item.value > 15
//            }
//
//            // Track selection
//            vm.onSelect { item in
//                selectedItem = item
//            }
//        }
//
//        // Try to select item with value < 15 (should fail)
//        #expect(!sut.canSelect(item: items[0]))
//        sut.select(item: items[0])
//        #expect(selectedItem == nil)
//
//        // Try to select item with value > 15 (should succeed)
//        #expect(sut.canSelect(item: items[1]))
//        sut.select(item: items[1])
//        #expect(selectedItem?.name == "Item 2")
//
//        // Test deselection
//        sut.select(item: nil)
//        #expect(selectedItem == nil)
//    }
//
//    @Test("Move behavior with canMove")
//    func moveWithCanMove() {
//        let items = [
//            TestItem(name: "Item 1", value: 10),
//            TestItem(name: "Item 2", value: 20),
//            TestItem(name: "Item 3", value: 30)
//        ]
//
//        let sut = FormCollectionViewModel<TestItem>(
//            value: items
//        )
//
//        // Configure move behavior
//        sut.configure { vm in
//            // Only allow moves where source is at index 0
//            vm.onCanMove { source, destination in
//                source.contains(0)
//            }
//        }
//
//        // Try valid move (from index 0)
//        let validSource = IndexSet(integer: 0)
//        #expect(sut.canMove(from: validSource, to: 2))
//        sut.move(from: validSource, to: 2)
//        #expect(sut.value[1].name == "Item 1") // Item moved to position 1
//
//        // Try invalid move (from index not 0)
//        let invalidSource = IndexSet(integer: 2)
//        #expect(!sut.canMove(from: invalidSource, to: 0))
//    }
//
//    @Test("Track collection changes with onChange")
//    func trackChanges() {
//        let sut = FormCollectionViewModel<TestItem>(
//            value: []
//        )
//
//        var changeCalled = false
//        var lastDifference: CollectionDifference<TestItem>?
//
//        // Configure change tracking
//        sut.configure { vm in
//            vm.onChange { difference in
//                changeCalled = true
//                lastDifference = difference
//            }
//        }
//
//        // Add item
//        let newItem = TestItem(name: "New Item", value: 50)
//        sut.value.append(newItem)
//
//        #expect(changeCalled)
//        #expect(lastDifference != nil)
//
//        // Verify we can identify insertions from the difference
//        var insertions = 0
//        if let diff = lastDifference {
//            for change in diff {
//                if case .insert = change {
//                    insertions += 1
//                }
//            }
//        }
//        #expect(insertions == 1)
//
//        // Reset tracking variables
//        changeCalled = false
//        lastDifference = nil
//
//        // Remove item
//        sut.value.removeLast()
//
//        #expect(changeCalled)
//        #expect(lastDifference != nil)
//
//        // Verify we can identify removals from the difference
//        var removals = 0
//        if let diff = lastDifference {
//            for change in diff {
//                if case .remove = change {
//                    removals += 1
//                }
//            }
//        }
//        #expect(removals == 1)
//    }
//
//    @Test("Method chaining works with configuration methods")
//    func methodChaining() {
//        let sut = FormCollectionViewModel<TestItem>(
//            value: []
//        )
//
//        var canSelectCalled = false
//        var canInsertCalled = false
//
//        let chainedResult = sut
//            .onCanSelect { _ in
//                canSelectCalled = true
//                return true
//            }
//            .onCanInsert {
//                canInsertCalled = true
//                return true
//            }
//
//        #expect(chainedResult === sut)  // Same instance returned
//
//        _ = sut.canSelect(item: TestItem(name: "Test", value: 0))
//        #expect(canSelectCalled == true)
//
//        _ = sut.canInsert()
//        #expect(canInsertCalled == true)
//    }
}
