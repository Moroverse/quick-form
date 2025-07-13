// RequiredRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 19:08 GMT.

/// A validation rule that ensures a value is not nil.
///
/// `RequiredRule` is a simple validation rule that checks whether a given optional
/// value is non-nil. This is useful for form fields where a value must be provided.
///
/// ## Features
/// - Validates that an optional value is not nil
/// - Generic over any type, allowing it to be used with any optional value
/// - Provides a standard error message for nil values
///
/// ## Example
///
/// ```swift
/// @QuickForm(PersonForm.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \PersonForm.country)
///     var country = AsyncPickerFieldViewModel(
///         type: String?.self,
///         title: "Country",
///         placeholder: "Select Country...",
///         validation: .of(.required()),
///         valuesProvider: { query in
///             try await countryLoader.loadCountries(query: query)
///         },
///         queryBuilder: { $0 ?? "" }
///     )
/// }
///
/// let model = PersonFormModel(model: PersonForm())
/// let countryResult = model.country.validate()
/// // countryResult will be .failure("This field is required")
///
/// model.country.value = "United States"
/// let updatedCountryResult = model.country.validate()
/// // updatedCountryResult will be .success
/// ```
public struct RequiredRule<T>: ValidationRule {
    /// Initializes a new `RequiredRule`.
    ///
    /// This initializer takes no parameters, as the rule simply checks for non-nil values.
    public init() {}

    /// Validates that the given value is not nil.
    ///
    /// - Parameter value: The optional value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    ///   Returns `.success` if the value is not nil, and `.failure` with an error message otherwise.
    public func validate(_ value: T?) -> ValidationResult {
        value != nil ? .success : .failure("This field is required")
    }
}

public extension ValidationRule {
    /// A convenience static property to create a `RequiredRule`.
    ///
    /// This allows for more readable code when using the rule, especially in combination with other rules.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(.required(), .minLength(5))
    /// ```
    static func required<T>() -> AnyValidationRule<T?> where Self == AnyValidationRule<T?> {
        AnyValidationRule<T?>(RequiredRule<T>())
    }
}
