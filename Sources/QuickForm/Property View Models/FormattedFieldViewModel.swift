// FormattedFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation

/// A view model for managing a form field with formatted input and output.
///
/// `FormattedFieldViewModel` is a generic class that handles the data, validation, and formatting
/// for a form field that requires specific input/output formatting. It conforms to both ``ObservableValueEditor``
/// and ``Validatable`` protocols, providing a complete solution for formatted form field management.
///
/// This class is particularly useful for fields like currency, numbers, percentages, or any other data that
/// needs to be displayed in a specific format while storing a different underlying value.
///
/// ## Features
/// - Manages the field's value, title, and placeholder
/// - Handles read-only state
/// - Provides built-in validation support
/// - Applies formatting to the field's value for display
/// - Allows for custom value change handling
///
/// ## Examples
///
/// ### Currency Formatting
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.salary)
///     var salary = FormattedFieldViewModel(
///         type: Decimal.self,
///         format: .currency(code: "USD"),
///         title: "Salary:",
///         placeholder: "$100,000"
///     )
/// }
/// ```
///
/// ### Phone Number Formatting
///
/// ```swift
/// @PropertyEditor(keyPath: \Person.phone)
/// var phone = FormattedFieldViewModel(
///     type: String?.self,
///     format: OptionalFormat(format: .usPhoneNumber(.parentheses)),
///     title: "Phone:",
///     placeholder: "(123) 456-7890"
/// )
/// ```
///
/// ### Using with FormFormattedTextField in SwiftUI
///
/// ```swift
/// struct PersonFormView: View {
///     @StateObject var model = PersonEditModel()
///
///     var body: some View {
///         Form {
///             // Currency field
///             FormFormattedTextField(model.salary)
///
///             // Phone number field
///             FormFormattedTextField(model.phone)
///                 .keyboardType(.phonePad)
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFormattedTextField``, ``ObservableValueEditor``, ``Validatable``, ``ParseableFormatStyle``
@Observable
public final class FormattedFieldViewModel<F>: ObservableValueEditor, Validatable
    where F: ParseableFormatStyle, F.FormatOutput == String {
    /// The title of the form field.
    ///
    /// This title is typically displayed as a label next to or above the form field
    /// to describe what information the field is collecting.
    public var title: LocalizedStringResource

    /// An optional placeholder text for the form field.
    ///
    /// The placeholder is shown when the field is empty and provides guidance to the user
    /// about what kind of information to enter.
    public var placeholder: LocalizedStringResource?

    /// The format style used to format the field's value.
    ///
    /// This property defines how the underlying value is formatted for display
    /// and how user input is parsed back into the underlying value type.
    ///
    /// When used with ``FormFormattedTextField``, this format is automatically applied
    /// to convert between the displayed text and the underlying value.
    ///
    /// - SeeAlso: ``ParseableFormatStyle``
    public var format: F

    /// The current value of the form field.
    ///
    /// When this value changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - Validation is performed and `validationResult` is updated
    /// - Any UI components bound to this value are updated
    public var value: F.FormatInput {
        didSet {
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// Returns the raw string representation of the current value.
    ///
    /// This property provides a string representation of the underlying value
    /// without applying any formatting. It's useful when you need the unformatted value
    /// for editing purposes or raw display.
    ///
    /// - If the value conforms to `CustomStringConvertible`, uses its `description` property
    /// - Otherwise, falls back to Swift's default string representation using `String(describing:)`
    ///
    /// ## Example
    ///
    /// ```swift
    /// let currency = FormattedFieldViewModel(
    ///     value: 1234.56,
    ///     format: .currency(code: "USD")
    /// )
    ///
    /// print(currency.rawStringValue) // "1234.56"
    /// print(format.format(currency.value)) // "$1,234.56"
    /// ```
    public var rawStringValue: String {
        if let convertible = value as? CustomStringConvertible {
            convertible.description
        } else {
            String(describing: value)
        }
    }

    /// A boolean indicating whether the field is read-only.
    ///
    /// When set to `true`, the field should not allow user interaction or changes.
    /// When used with ``FormFormattedTextField``, this property automatically disables editing
    /// and applies an appropriate visual style to indicate the read-only state.
    public var isReadOnly: Bool

    /// The event dispatcher for value changes.
    private var dispatcher: Dispatcher

    /// The validation rule to apply to the field's value.
    private let validation: AnyValidationRule<F.FormatInput?>?

    /// The current validation state of the field.
    ///
    /// This property is updated whenever the `value` property changes or when `validate()`
    /// is called explicitly. When used with ``FormFormattedTextField`` and `showValidation(true)`,
    /// validation errors are displayed automatically in the UI.
    private(set) var validationResult: ValidationResult = .success

    /// Initializes a new instance of ``FormattedFieldViewModel``.
    ///
    /// - Parameters:
    ///   - value: The initial value of the form field.
    ///   - format: The format style to use for this field.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let phoneField = FormattedFieldViewModel(
    ///     value: "",
    ///     format: .usPhoneNumber(.parentheses),
    ///     title: "Phone:",
    ///     placeholder: "Enter phone number",
    ///     validation: nil
    /// )
    ///
    /// // Use the field in a SwiftUI view
    /// var body: some View {
    ///     FormFormattedTextField(phoneField)
    ///         .keyboardType(.phonePad)
    /// }
    /// ```
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
    public func onValueChanged(_ change: @escaping (F.FormatInput) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}

public extension FormattedFieldViewModel where F.FormatInput: DefaultValueProvider {
    /// Convenience initializer that uses the default value of the input type.
    ///
    /// - Parameters:
    ///   - type: The type of formatted input.
    ///   - format: The format style to use for this field.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    convenience init(
        type: F.FormatInput.Type,
        format: F,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<F.FormatInput?>? = nil
    ) {
        self.init(
            value: F.FormatInput.defaultValue,
            format: format,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation
        )
    }
}
