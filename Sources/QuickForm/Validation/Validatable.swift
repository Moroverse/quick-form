// Validatable.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-10 17:44 GMT.

import Foundation

/// A protocol that provides validation functionality for form models.
///
/// Types conforming to `Validatable` can perform self-validation and report the results.
/// This protocol is typically used in conjunction with the `@QuickForm` macro to provide
/// automatic validation for form models.
///
/// Conforming types must implement the `validate()` method, which returns a `ValidationResult`.
/// They also get default implementations for `isValid` and `errorMessage` properties.
///
/// ## Example
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name:",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     func validate() -> ValidationResult {
///         // Custom validation logic
///         if firstName.value.isEmpty && lastName.value.isEmpty {
///             return .failure("Both first name and last name cannot be empty")
///         }
///         return .success
///     }
/// }
///
/// let model = PersonEditModel(model: Person())
/// if model.isValid {
///     print("Form is valid")
/// } else {
///     print("Validation failed: \(model.errorMessage ?? "")")
/// }
/// ```
public protocol Validatable {
    /// Performs validation and returns the result.
    ///
    /// Implement this method to define custom validation logic for your form model.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    func validate() -> ValidationResult
}

public extension Validatable {
    /// A Boolean value indicating whether the current state is valid.
    var isValid: Bool {
        switch validate() {
        case .success:
            true

        case .failure:
            false
        }
    }

    /// The error message if validation fails, or `nil` if validation succeeds.
    var errorMessage: LocalizedStringResource? {
        switch validate() {
        case .success:
            nil

        case let .failure(message):
            message
        }
    }
}
