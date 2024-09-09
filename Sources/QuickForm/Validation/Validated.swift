// Validated.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

@propertyWrapper
public struct Validated<Value> {
    private var value: Value
    let rule: AnyValidationRule<Value>

    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    public var validationResult: ValidationResult {
        rule.validate(value)
    }

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

    public init(wrappedValue: Value, _ rule: AnyValidationRule<Value>) {
        value = wrappedValue
        self.rule = rule
    }
}
