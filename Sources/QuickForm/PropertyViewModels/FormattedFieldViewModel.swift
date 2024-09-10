// FormattedFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import Foundation
import Observation

@Observable
public final class FormattedFieldViewModel<F>: ValueEditor, Validatable
    where F: ParseableFormatStyle, F.FormatOutput == String {
    public var title: LocalizedStringResource
    public var placeholder: LocalizedStringResource?
    public var format: F
    public var value: F.FormatInput {
        didSet {
            valueChanged?(value)
            validationResult = validate()
        }
    }

    public var isReadOnly: Bool

    private var valueChanged: ((F.FormatInput) -> Void)?
    private let validation: AnyValidationRule<F.FormatInput?>?
    private var validationResult: ValidationResult = .success

    public init(
        value: F.FormatInput,
        format: F,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<F.FormatInput?>? = nil
    ) {
        self.value = value
        self.format = format
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        validationResult = validate()
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (F.FormatInput) -> Void) -> Self {
        valueChanged = change
        return self
    }

    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}
