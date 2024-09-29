// FormattedFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import Foundation
import Observation

/// A view model for managing a form field with formatted input and output.
///
/// `FormattedFieldViewModel` is a generic class that handles the data, validation, and formatting
/// for a form field that requires specific input/output formatting. It conforms to both `ValueEditor`
/// and `Validatable` protocols, providing a complete solution for formatted form field management.
///
/// This class is particularly useful for fields like currency, dates, or any other data that
/// needs to be displayed in a specific format while storing a different underlying value.
///
/// ## Features
/// - Manages the field's value, title, and placeholder
/// - Handles read-only state
/// - Provides built-in validation support
/// - Applies formatting to the field's value for display
/// - Allows for custom value change handling
///
/// ## Example
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.salary)
///     var salary = FormattedFieldViewModel(
///         value: 50000.0,
///         format: .currency(code: "USD"),
///         title: "Salary:",
///         placeholder: "Enter annual salary",
///         validation: AnyValidationRule { value in
///             guard value >= 0 else {
///                 return .failure("Salary must be non-negative")
///             }
///             return .success
///         }
///     )
/// }
/// ```
@Observable
public final class FormattedFieldViewModel<F>: ValueEditor, Validatable
    where F: ParseableFormatStyle, F.FormatOutput == String {
    /// The title of the form field.
    public var title: LocalizedStringResource
    /// An optional placeholder text for the form field.
    public var placeholder: LocalizedStringResource?
    /// The format style used to format the field's value.
    public var format: F
    /// The current value of the form field.
    public var value: F.FormatInput {
        didSet {
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool

    private var dispatcher: Dispatcher
    private let validation: AnyValidationRule<F.FormatInput?>?
    private var validationResult: ValidationResult = .success
    /// Initializes a new instance of `FormattedFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial value of the form field.
    ///   - format: The format style to use for this field.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    public init(
        value: F.FormatInput,
        format: F,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<F.FormatInput?>? = nil
    ) {
        self.value = value
        self.format = format
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        dispatcher = Dispatcher()
        validationResult = validate()
    }

    /// Sets a closure to be called when the value changes.
    ///
    /// - Parameter change: A closure that takes the new value as its parameter.
    /// - Returns: The `FormattedFieldViewModel` instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (F.FormatInput) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}
