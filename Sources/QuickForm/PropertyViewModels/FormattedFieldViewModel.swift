// FormattedFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import Foundation
import Observation

@Observable
public final class FormattedFieldViewModel<F>: ValueEditor where F: ParseableFormatStyle, F.FormatOutput == String {
    public var title: LocalizedStringResource
    public var placeholder: LocalizedStringResource?
    public var format: F
    public var value: F.FormatInput {
        didSet {
            valueChanged?(value)
            validate()
        }
    }

    public var isReadOnly: Bool

    public var isValid: Bool {
        switch validationResult {
        case .success:
            true

        case .failure:
            false
        }
    }

    public var errorMessage: LocalizedStringResource? {
        switch validationResult {
        case .success:
            nil

        case let .failure(error):
            error
        }
    }

    private var valueChanged: ((F.FormatInput) -> Void)?
    private let validation: AnyValidationRule<F.FormatInput>?
    private var validationResult: ValidationResult = .success

    public init(
        value: F.FormatInput,
        format: F,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<F.FormatInput>? = nil
    ) {
        self.value = value
        self.format = format
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        validate()
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (F.FormatInput) -> Void) -> Self {
        valueChanged = change
        return self
    }

    private func validate() {
        validationResult = validation?.validate(value) ?? .success
    }
}
