// AnyValidationRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation
/// A type-erasing wrapper for validation rules.
///
/// `AnyValidationRule` allows you to use different validation rules interchangeably,
/// hiding their specific types. It also provides methods for combining multiple
/// validation rules into a single rule.
///
/// This struct is particularly useful when you need to store validation rules of
/// different types in the same collection, or when you want to combine multiple
/// rules into a single, more complex rule.
///
/// ## Features
/// - Type-erases any `ValidationRule`
/// - Allows combining multiple validation rules
/// - Provides a convenience method for creating a single validation rule
///
/// ## Example
///
/// ```swift
/// // Define some validation rules
/// struct MinLengthRule: ValidationRule {
///     let minLength: Int
///     func validate(_ value: String) -> ValidationResult {
///         value.count >= minLength ? .success : .failure("Must be at least \(minLength) characters")
///     }
/// }
///
/// struct ContainsUppercaseRule: ValidationRule {
///     func validate(_ value: String) -> ValidationResult {
///         value.contains { $0.isUppercase } ? .success : .failure("Must contain an uppercase letter")
///     }
/// }
///
/// // Combine rules using AnyValidationRule
/// let passwordRule = AnyValidationRule.combined(
///     MinLengthRule(minLength: 8),
///     ContainsUppercaseRule()
/// )
///
/// // Use the combined rule
/// let result = passwordRule.validate("password")
/// // result will be .failure("Must be at least 8 characters")
///
/// let result2 = passwordRule.validate("Password123")
/// // result2 will be .success
/// ```
public struct AnyValidationRule<Value>: ValidationRule {
    private let _validate: (Value) -> ValidationResult
    /// Initializes a new `AnyValidationRule` wrapping the given validation rule.
    ///
    /// - Parameter rule: The validation rule to wrap.
    public init<R: ValidationRule>(_ rule: R) where R.Value == Value {
        _validate = rule.validate
    }

    private init(validate: @escaping (Value) -> ValidationResult) {
        _validate = validate
    }
    /// Validates the given value using the wrapped validation rule.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate(_ value: Value) -> ValidationResult {
        _validate(value)
    }

    /// Combines multiple validation rules into a single `AnyValidationRule`.
    ///
    /// This method creates a new validation rule that applies all the given rules in sequence.
    /// If any rule fails, the combined rule returns that failure result. If all rules pass,
    /// the combined rule returns success.
    ///
    /// - Parameter rules: The validation rules to combine.
    /// - Returns: A new `AnyValidationRule` that combines all the given rules.
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

    /// Creates an `AnyValidationRule` from a single validation rule.
    ///
    /// This is a convenience method that wraps a single validation rule in an `AnyValidationRule`.
    ///
    /// - Parameter rule: The validation rule to wrap.
    /// - Returns: A new `AnyValidationRule` that wraps the given rule.
    public static func of<R: ValidationRule>(_ rule: R) -> AnyValidationRule<Value> where R.Value == Value {
        Self(rule)
    }
}
