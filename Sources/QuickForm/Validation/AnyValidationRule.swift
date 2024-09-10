// AnyValidationRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

public struct AnyValidationRule<Value>: ValidationRule {
    private let _validate: (Value) -> ValidationResult

    public init<R: ValidationRule>(_ rule: R) where R.Value == Value {
        _validate = rule.validate
    }

    private init(validate: @escaping (Value) -> ValidationResult) {
        _validate = validate
    }

    public func validate(_ value: Value) -> ValidationResult {
        _validate(value)
    }

    // Factory method for combining rules
    public static func combined<each Rule: ValidationRule>(_ rules: repeat each Rule) -> AnyValidationRule<Value> {
        var packed: [any ValidationRule<Value>] = []

        func add(element: some ValidationRule) {
            if let validationElement = element as? any ValidationRule<Value> {
                packed.append(validationElement)
            }
        }

        repeat add(element: each rules)

        return Self { value in
            for rule in packed {
                let anyRule = Self(rule)
                switch anyRule.validate(value) {
                case .success:
                    continue

                case let .failure(error):
                    return .failure(error)
                }
            }
            return .success
        }
    }

    // Factory method for single rule
    public static func of<R: ValidationRule>(_ rule: R) -> AnyValidationRule<Value> where R.Value == Value {
        Self(rule)
    }
}
