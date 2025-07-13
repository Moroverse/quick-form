// MinLengthRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

/// A validation rule that ensures a string value meets a minimum length requirement.
///
/// `MinLengthRule` is a validation rule that checks whether a given string value
/// has at least a specified number of characters. This is useful for form fields
/// where a minimum input length is required, such as passwords or usernames.
///
/// ## Features
/// - Validates that a string meets a minimum length requirement
/// - Provides a customizable minimum length
/// - Generates an appropriate error message based on the minimum length
/// - Can be easily combined with other validation rules
///
/// ## Example
///
/// ```swift
/// @QuickForm(UserForm.self)
/// class UserFormModel: Validatable {
///     @PropertyEditor(keyPath: \UserForm.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \UserForm.password)
///     var password = FormFieldViewModel(
///         type: String.self,
///         title: "Password:",
///         placeholder: "P@$$w0rd",
///         validation: .combined(.notEmpty, .minLength(8))
///     )
/// }
///
/// let model = UserFormModel(model: UserForm())
/// let firstNameResult = model.firstName.validate()
/// // firstNameResult will be .failure("This field must be at least 2 characters long")
///
/// model.firstName.value = "John"
/// let updatedFirstNameResult = model.firstName.validate()
/// // updatedFirstNameResult will be .success
/// ```
public struct MinLengthRule: ValidationRule {
    /// The minimum length required for the string to be valid.
    let minLength: Int

    /// Initializes a new `MinLengthRule` with the specified minimum length.
    ///
    /// - Parameter length: The minimum number of characters required for the string to be valid.
    public init(length: Int) {
        minLength = length
    }

    /// Validates that the given string value meets the minimum length requirement.
    ///
    /// - Parameter value: The string value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the string length is at least `minLength`,
    ///   and `.failure` with an error message otherwise.
    public func validate(_ value: String) -> ValidationResult {
        value.count < minLength ? .failure("This field must be at least \(minLength) characters long") : .success
    }
}

public extension ValidationRule where Self == MinLengthRule {
    /// A convenience static method to create a `MinLengthRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// - Parameter length: The minimum number of characters required for the string to be valid.
    /// - Returns: A `MinLengthRule` instance with the specified minimum length.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.notEmpty, .minLength(8))
    /// ```
    static func minLength(_ length: Int) -> MinLengthRule {
        MinLengthRule(length: length)
    }
}
