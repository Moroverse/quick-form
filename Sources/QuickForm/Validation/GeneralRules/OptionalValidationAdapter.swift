// OptionalValidationAdapter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:36 GMT.

import Foundation

struct OptionalValidationAdapter<Rule: ValidationRule>: ValidationRule {
    private let rule: Rule
    private let requireNonNil: Bool

    init(
        _ rule: Rule,
        requireNonNil: Bool = false
    ) {
        self.rule = rule
        self.requireNonNil = requireNonNil
    }

    func validate(_ value: Rule.Value?) -> ValidationResult {
        guard let value else {
            return requireNonNil ? .failure("This field is required") : .success
        }

        return rule.validate(value)
    }
}

public enum OptionalRule {
    /// Creates a validation rule that applies any rule to an optional value, if present
    public static func ifPresent<R: ValidationRule>(_ rule: R) -> AnyValidationRule<R.Value?> {
        AnyValidationRule(OptionalValidationAdapter(rule))
    }

    /// Creates a validation rule that requires a non-nil value and applies the given rule
    public static func required<R: ValidationRule>(
        _ rule: R
    ) -> AnyValidationRule<R.Value?> {
        AnyValidationRule(OptionalValidationAdapter(rule, requireNonNil: true))
    }
}
