// TokenSetViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:00 GMT.

import Foundation
import Observation

@Observable
public final class TokenSetViewModel<Property: Identifiable & CustomStringConvertible>: ValueEditor {
    private var insertionMapper: ((String) -> Property?)?
    private var _onSelect: ((Property?) -> Void)?

    var canInsert: Bool { insertionPlaceholder != nil }

    public var title: LocalizedStringResource?
    public var insertionPlaceholder: LocalizedStringResource?
    public var onCanDelete: (_ value: Property) -> Bool = { _ in true }
    public var selection: Property.ID? {
        didSet {
            if let _onSelect, let value = value.first(where: { $0.id == self.selection }) {
                _onSelect(value)
            }
        }
    }

    public var value: [Property]

    public init(value: [Property], title: LocalizedStringResource? = nil, insertionPlaceholder: LocalizedStringResource?, insertionMapper: ((String) -> Property?)? = nil) {
        self.title = title
        self.value = value
        self.insertionPlaceholder = insertionPlaceholder
        self.insertionMapper = insertionMapper
    }

    public func insert(_ input: String) -> Bool {
        guard let mapper = insertionMapper else { return false }
        if let newValue = mapper(input) {
            value.append(newValue)
            return true
        } else {
            return false
        }
    }

    public func remove(id: Property.ID?) {
        value.removeAll(where: { $0.id == id })
    }

    @discardableResult
    public func onSelect(action: ((Property?) -> Void)?) -> Self {
        _onSelect = action
        return self
    }

    public func canDelete(_ value: Property) -> Bool {
        onCanDelete(value)
    }
}
