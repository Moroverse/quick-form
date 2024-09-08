// FormFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation
import Foundation

@Observable
public final class FormFieldViewModel<Property>: ValueEditor {
    public var title: LocalizedStringResource
    public var placeholder: LocalizedStringResource?
    public var value: Property {
        didSet {
            valueChanged?(value)
        }
    }
    public var isReadOnly: Bool
    private var valueChanged: ((Property) -> Void)?

    public init(
        value: Property,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false
    ) {
        _value = value
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
        valueChanged = change
        return self
    }
}
