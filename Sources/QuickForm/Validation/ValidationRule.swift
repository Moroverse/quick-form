// ValidationRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

/// A protocol that defines a rule for validating a specific type of value.
///
/// `ValidationRule` is a generic protocol that allows you to create reusable validation logic
/// for different types of values. It's commonly used in conjunction with `FormFieldViewModel`
/// and other form-related components in the QuickForm package.
///
/// Conforming types must implement the `validate(_:)` method, which takes a value of the
/// associated `Value` type and returns a `ValidationResult`.
///
/// ## Example
///
/// Here's an example of a custom validation rule that checks if a string contains a specific substring:
///
/// ```swift
/// struct ContainsSubstringRule: ValidationRule {
///     let substring: String
///     let caseSensitive: Bool
///
///     init(substring: String, caseSensitive: Bool = false) {
///         self.substring = substring
///         self.caseSensitive = caseSensitive
///     }
///
///     func validate(_ value: String) -> ValidationResult {
///         let string = caseSensitive ? value : value.lowercased()
///         let target = caseSensitive ? substring : substring.lowercased()
///
///         if string.contains(target) {
///             return .success
///         } else {
///             return .failure("Value must contain '\(substring)'")
///         }
///     }
/// }
///
/// // Usage:
/// let rule = ContainsSubstringRule(substring: "hello", caseSensitive: false)
/// let result = rule.validate("Hello, world!")
/// // result will be .success
/// ```
///
/// You can also combine multiple validation rules using `AnyValidationRule`:
///
/// ```swift
/// let combinedRule = AnyValidationRule.combined(
///     NotEmptyRule(),
///     MinLengthRule(length: 5),
///     ContainsSubstringRule(substring: "@")
/// )
///
/// let emailResult = combinedRule.validate("user@example.com")
/// // emailResult will be .success
/// ```
public protocol ValidationRule<Value> {
    /// The type of value this rule can validate.
    associatedtype Value
    /// Validates the given value and returns a validation result.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    func validate(_ value: Value) -> ValidationResult
}

/// Represents the outcome of a validation operation.
///
/// `ValidationResult` is an enum that encapsulates the result of validating a form field or an entire form.
/// It has two cases: `success` for when the validation passes, and `failure` for when it fails,
/// with an associated error message.
///
/// This enum is used throughout the QuickForm package to communicate validation outcomes,
/// allowing for consistent handling of validation results across different components.
///
/// ## Usage
///
/// `ValidationResult` is typically returned by validation methods and can be used to determine
/// if a field or form is valid and to retrieve error messages when validation fails.
///
/// ## Example
///
/// ```swift
/// struct PasswordRule: ValidationRule {
///     func validate(_ value: String) -> ValidationResult {
///         if value.count >= 8 {
///             return .success
///         } else {
///             return .failure("Password must be at least 8 characters long")
///         }
///     }
/// }
///
/// let passwordRule = PasswordRule()
/// let result = passwordRule.validate("short")
///
/// switch result {
/// case .success:
///     print("Password is valid")
/// case .failure(let errorMessage):
///     print("Validation failed: \(errorMessage)")
/// }
/// ```
///
/// In this example, the `ValidationResult` is used to determine if a password meets
/// the required length and to provide an error message if it doesn't.
public enum ValidationResult: Equatable {
    /// Indicates that the validation was successful.
    case success

    /// Indicates that the validation failed, with an associated error message.
    ///
    /// - Parameter LocalizedStringResource: A localized string resource containing the error message.
    case failure(LocalizedStringResource)
}
