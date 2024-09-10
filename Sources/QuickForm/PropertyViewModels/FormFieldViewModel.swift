// FormFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import Observation

@Observable
public final class FormFieldViewModel<Property>: ValueEditor, Validatable {
    public var title: LocalizedStringResource
    public var placeholder: LocalizedStringResource?
    public var value: Property {
        didSet {
            valueChanged?(value)
            validationResult = validate()
        }
    }

    public var isReadOnly: Bool

    private var valueChanged: ((Property) -> Void)?
    private let validation: AnyValidationRule<Property>?
    private var validationResult: ValidationResult = .success

    public init(
        value: Property,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property>? = nil
    ) {
        _value = value
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        validationResult = validate()
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
        valueChanged = change
        return self
    }

    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}
