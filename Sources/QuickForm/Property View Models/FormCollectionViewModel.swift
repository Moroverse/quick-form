//
//  FormFieldViewModel 2.swift
//  quick-form
//
//  Created by Daniel Moro on 8.9.24..
//

import Observation
import Foundation

@Observable
public final class FormCollectionViewModel<Property: Identifiable>: ValueEditor {
    public var title: String
    public var value: [Property] {
        didSet {
            if let collectionChanged = collectionChanged {
                collectionChanged(value.difference(from: oldValue) { $0.id == $1.id })
            }
        }
    }
    public var isReadOnly: Bool
    private var collectionChanged: ((CollectionDifference<Property>) -> Void)?
    private var insertValue: (() async -> Property)?

    public init(
        value: [Property],
        title: String = "",
        isReadOnly: Bool = false
    ) {
        _value = value
        self.title = title
        self.isReadOnly = isReadOnly
    }

    public func insert() async {
        if let insertValue = insertValue {
            await value.append(insertValue())
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
    public func onInsert(_ insert: @escaping () async -> Property) -> Self {
        insertValue = insert
        return self
    }
}
