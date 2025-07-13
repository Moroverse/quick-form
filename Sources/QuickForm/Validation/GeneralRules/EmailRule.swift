// EmailRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

/// A validation rule that ensures a string value is a valid email address.
///
/// `EmailRule` is a validation rule that checks whether a given string value
/// conforms to a valid email address format using regular expression pattern matching.
/// This is useful for form fields where a valid email address is required.
///
/// ## Features
/// - Validates that a string is a properly formatted email address
/// - Uses RFC-compliant email validation pattern
/// - Provides a clear error message for invalid email formats
/// - Can be easily combined with other validation rules
///
/// ## Example
///
/// ```swift
/// @QuickForm(PersonForm.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \PersonForm.email)
///     var email = FormFieldViewModel(
///         type: String.self,
///         title: "Email",
///         placeholder: "johndoe@example.com",
///         validation: .of(.email)
///     )
///
///     @PropertyEditor(keyPath: \PersonForm.workEmail)
///     var workEmail = FormFieldViewModel(
///         type: String.self,
///         title: "Work Email",
///         placeholder: "john@company.com",
///         validation: .combined(.notEmpty, .email)
///     )
/// }
///
/// let model = PersonFormModel(model: PersonForm())
/// model.email.value = "invalid-email"
/// let emailResult = model.email.validate()
/// // emailResult will be .failure("Please enter a valid email address")
///
/// model.email.value = "johndoe@example.com"
/// let updatedEmailResult = model.email.validate()
/// // updatedEmailResult will be .success
/// ```
public struct EmailRule: ValidationRule {
    /// Initializes a new `EmailRule`.
    ///
    /// This initializer takes no parameters, as the rule uses a standard email validation pattern.
    public init() {}
    
    /// Validates that the given string value is a properly formatted email address.
    ///
    /// - Parameter value: The string value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the string is a valid email format, and `.failure` with an error message otherwise.
    public func validate(_ value: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: value) ? .success : .failure("Please enter a valid email address")
    }
}

public extension ValidationRule where Self == EmailRule {
    /// A convenience static property to create an `EmailRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.notEmpty, .email)
    /// ```
    static var email: EmailRule { EmailRule() }
}
