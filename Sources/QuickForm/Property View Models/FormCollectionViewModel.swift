// FormCollectionViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation
import Foundation

@Observable
public final class FormCollectionViewModel<Property: Identifiable>: ValueEditor {
    public var title: LocalizedStringResource
    public var insertionTitle: LocalizedStringResource
    public var value: [Property] {
        didSet {
            if let collectionChanged {
                collectionChanged(value.difference(from: oldValue) { $0.id == $1.id })
            }
        }
    }
    public var isReadOnly: Bool
    private var collectionChanged: ((CollectionDifference<Property>) -> Void)?
    private var insertValue: (() async -> Property?)?

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

    public func insert() async {
        if let insertValue {
            if let personInfo = await insertValue() {
                value.append(personInfo)
            }
        }
    }

    func delete(at offsets: IndexSet) {
        value.remove(atOffsets: offsets)
    }

    @discardableResult
    public func onCollectionChanged(_ change: @escaping (CollectionDifference<Property>) -> Void) -> Self {
        collectionChanged = change
        return self
    }

    @discardableResult
    public func onInsert(_ insert: @escaping () async -> Property?) -> Self {
        insertValue = insert
        return self
    }
}
