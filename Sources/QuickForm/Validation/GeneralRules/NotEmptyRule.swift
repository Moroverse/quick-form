// NotEmptyRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

/// A validation rule that ensures a string value is not empty.
///
/// `NotEmptyRule` is a simple validation rule that checks whether a given string
/// value is not empty (i.e., has at least one character). This is useful for form
/// fields where a non-empty string input is required.
///
/// ## Features
/// - Validates that a string is not empty
/// - Provides a standard error message for empty strings
/// - Can be easily combined with other validation rules
///
/// ## Example
///
/// ```swift
/// @QuickForm(PersonForm.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \PersonForm.name)
///     var name = FormFieldViewModel(
///         value: "",
///         title: "Name:",
///         validation: .of(.notEmpty)
///     )
///
///     @PropertyEditor(keyPath: \PersonForm.email)
///     var email = FormFieldViewModel(
///         value: "",
///         title: "Email:",
///         validation: .combined(.notEmpty, .email)
///     )
/// }
///
/// let model = PersonFormModel(model: PersonForm())
/// let nameResult = model.name.validate()
/// // nameResult will be .failure("This field cannot be empty")
///
/// model.name.value = "John Doe"
/// let updatedNameResult = model.name.validate()
/// // updatedNameResult will be .success
/// ```
public struct NotEmptyRule: ValidationRule {
    /// Initializes a new `NotEmptyRule`.
    ///
    /// This initializer takes no parameters, as the rule simply checks for non-empty strings.
    public init() {}

    /// Validates that the given string value is not empty.
    ///
    /// - Parameter value: The string value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the string is not empty, and `.failure` with an error message otherwise.
    public func validate(_ value: String) -> ValidationResult {
        value.isEmpty ? .failure("This field cannot be empty") : .success
    }
}

public extension ValidationRule where Self == NotEmptyRule {
    /// A convenience static property to create a `NotEmptyRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.notEmpty, .email)
    /// ```
    static var notEmpty: NotEmptyRule { NotEmptyRule() }
}
