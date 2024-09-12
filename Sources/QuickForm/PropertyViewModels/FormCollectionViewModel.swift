// FormCollectionViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 13:42 GMT.

import Foundation
import Observation

@Observable
public final class FormCollectionViewModel<Property: Identifiable>: ValueEditor {
    public var title: LocalizedStringResource
    public var insertionTitle: LocalizedStringResource
    public var value: [Property] {
        didSet {
            if let collectionChanged = onChange {
                collectionChanged(value.difference(from: oldValue) { $0.id == $1.id })
            }
        }
    }

    public var isReadOnly: Bool
    public var onCanSelect: (Property) -> Bool = { _ in true }
    public var onCanInsert: () -> Bool = { true }
    public var onCanDelete: (_ atOffsets: IndexSet) -> Bool = { _ in true }
    public var onCanMove: (_ fromSource: IndexSet, _ toDestination: Int) -> Bool = { _, _ in true }
    public var onInsert: (() async -> Property?)?
    public var onChange: ((CollectionDifference<Property>) -> Void)?
    public var onSelect: ((Property?) -> Void)?

    public init(
        value: [Property],
        title: LocalizedStringResource = "",
        insertionTitle: LocalizedStringResource = "Add",
        isReadOnly: Bool = false
    ) {
        _value = value
        self.title = title
        self.insertionTitle = insertionTitle
        self.isReadOnly = isReadOnly
    }

    public func canInsert() -> Bool {
        onCanInsert()
    }

    public func insert() async {
        if let insertion = onInsert {
            if let personInfo = await insertion() {
                value.append(personInfo)
            }
        }
    }

    public func canSelect(item: Property) -> Bool {
        onCanSelect(item)
    }

    public func select(item: Property?) {
        onSelect?(item)
    }

    public func canDelete(at offsets: IndexSet) -> Bool {
        onCanDelete(offsets)
    }

    public func delete(at offsets: IndexSet) {
        value.remove(atOffsets: offsets)
    }

    public func canMove(from source: IndexSet, to destination: Int) -> Bool {
        onCanMove(source, destination)
    }

    public func move(from source: IndexSet, to destination: Int) {
        value.move(fromOffsets: source, toOffset: destination)
    }
}
