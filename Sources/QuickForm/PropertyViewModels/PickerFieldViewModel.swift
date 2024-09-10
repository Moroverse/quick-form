// PickerFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import Observation

@Observable
public final class PickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ValueEditor {
    public var title: LocalizedStringResource
    public var allValues: [Property]
    public var value: Property {
        didSet {
            valueChanged?(value)
        }
    }

    public var isReadOnly: Bool

    private var valueChanged: ((Property) -> Void)?

    public init(
        value: Property,
        allValues: [Property],
        title: LocalizedStringResource = "",
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.isReadOnly = isReadOnly
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
        valueChanged = change
        return self
    }
}

@Observable
public final class OptionalPickerFieldViewModel<Property: Hashable & CustomStringConvertible>:
    ValueEditor, Validatable {
    public var title: String
    public var allValues: [Property]
    public var value: Property? {
        didSet {
            validationResult = validate()
        }
    }

    public var isReadOnly: Bool
    public var validation: AnyValidationRule<Property?>?

    private var validationResult: ValidationResult = .success

    public init(
        value: Property?,
        allValues: [Property],
        title: String = "",
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property?>? = nil
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.isReadOnly = isReadOnly
        self.validation = validation
        validationResult = validate()
    }

    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}
