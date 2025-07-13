// MaxLengthRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

/// A validation rule that ensures a string value does not exceed a maximum length.
///
/// `MaxLengthRule` is a validation rule that checks whether a given string value
/// has no more than a specified number of characters. This is useful for form fields
/// where there's a limit on input length, such as usernames, comments, or other
/// text fields with character limits.
///
/// ## Features
/// - Validates that a string does not exceed a maximum length
/// - Provides a customizable maximum length
/// - Generates an appropriate error message based on the maximum length
/// - Can be easily combined with other validation rules
///
/// ## Example
///
/// ```swift
/// @QuickForm(PostForm.self)
/// class PostFormModel: Validatable {
///     @PropertyEditor(keyPath: \PostForm.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \PostForm.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name:",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
/// }
///
/// let model = PostFormModel(model: PostForm())
/// model.firstName.value = "This is a very long first name that exceeds the maximum allowed length"
/// let firstNameResult = model.firstName.validate()
/// // firstNameResult will be .failure("This field must not exceed 50 characters")
///
/// model.firstName.value = "John"
/// let updatedFirstNameResult = model.firstName.validate()
/// // updatedFirstNameResult will be .success
/// ```
public struct MaxLengthRule: ValidationRule {
    /// The maximum length allowed for the string to be valid.
    let maxLength: Int

    /// Initializes a new `MaxLengthRule` with the specified maximum length.
    ///
    /// - Parameter length: The maximum number of characters allowed for the string to be valid.
    public init(length: Int) {
        maxLength = length
    }

    /// Validates that the given string value does not exceed the maximum length.
    ///
    /// - Parameter value: The string value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the string length is no more than `maxLength`,
    ///   and `.failure` with an error message otherwise.
    public func validate(_ value: String) -> ValidationResult {
        value.count > maxLength ? .failure("This field must not exceed \(maxLength) characters") : .success
    }
}

public extension ValidationRule where Self == MaxLengthRule {
    /// A convenience static method to create a `MaxLengthRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// - Parameter length: The maximum number of characters allowed for the string to be valid.
    /// - Returns: A `MaxLengthRule` instance with the specified maximum length.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.notEmpty, .minLength(5), .maxLength(50))
    /// ```
    static func maxLength(_ length: Int) -> MaxLengthRule {
        MaxLengthRule(length: length)
    }
}
