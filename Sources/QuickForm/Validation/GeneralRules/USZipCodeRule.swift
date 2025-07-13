// USZipCodeRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 19:45 GMT.

import Foundation

/// A validation rule that ensures a string value is a valid US ZIP code.
///
/// `USZipCodeRule` is a validation rule that checks whether a given string value
/// conforms to the standard US ZIP code format. It supports both 5-digit ZIP codes
/// (e.g., "12345") and ZIP+4 codes with extended format (e.g., "12345-6789").
///
/// ## Features
/// - Validates standard 5-digit US ZIP codes
/// - Supports ZIP+4 extended format with hyphen separator
/// - Uses regular expression pattern matching for accurate validation
/// - Provides a clear error message for invalid ZIP code formats
/// - Can be easily combined with other validation rules
///
/// ## Example
///
/// ```swift
/// @QuickForm(AddressForm.self)
/// class AddressFormModel: Validatable {
///     @PropertyEditor(keyPath: \AddressForm.zipCode)
///     var zipCode = FormFieldViewModel(
///         type: String.self,
///         title: "ZIP Code",
///         placeholder: "12345",
///         validation: .combined(.notEmpty, .usZipCode)
///     )
///
///     @PropertyEditor(keyPath: \AddressForm.zip)
///     var zip = FormFieldViewModel(
///         type: String.self,
///         title: "ZIP",
///         placeholder: "ZIP",
///         validation: .of(.usZipCode)
///     )
/// }
///
/// let model = AddressFormModel(model: AddressForm())
/// model.zipCode.value = "invalid-zip"
/// let zipResult = model.zipCode.validate()
/// // zipResult will be .failure("Please enter a valid US ZIP code (e.g., 12345 or 12345-6789)")
///
/// model.zipCode.value = "90210"
/// let updatedZipResult = model.zipCode.validate()
/// // updatedZipResult will be .success
///
/// model.zipCode.value = "90210-1234"
/// let extendedZipResult = model.zipCode.validate()
/// // extendedZipResult will be .success
/// ```
public struct USZipCodeRule: ValidationRule {
    /// Initializes a new `USZipCodeRule`.
    ///
    /// This initializer takes no parameters, as the rule uses a standard US ZIP code validation pattern.
    public init() {}
    
    /// Validates that the given string value is a properly formatted US ZIP code.
    ///
    /// This method checks for both standard 5-digit ZIP codes and extended ZIP+4 format.
    /// Valid formats include:
    /// - 5-digit ZIP codes: "12345"
    /// - ZIP+4 codes: "12345-6789"
    ///
    /// - Parameter value: The string value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the string is a valid US ZIP code format, and `.failure` with an error message otherwise.
    public func validate(_ value: String) -> ValidationResult {
        let zipCodeRegex = #"^\d{5}(-\d{4})?$"#
        let zipCodePredicate = NSPredicate(format: "SELF MATCHES %@", zipCodeRegex)

        return zipCodePredicate.evaluate(with: value)
            ? .success
            : .failure("Please enter a valid US ZIP code (e.g., 12345 or 12345-6789)")
    }
}

public extension ValidationRule where Self == USZipCodeRule {
    /// A convenience static property to create a `USZipCodeRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.notEmpty, .usZipCode)
    /// ```
    static var usZipCode: USZipCodeRule { USZipCodeRule() }
}
