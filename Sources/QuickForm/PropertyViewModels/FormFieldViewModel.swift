// FormFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import Observation

/// A view model for managing a single form field's state and behavior.
///
/// `FormFieldViewModel` is a generic class that handles the data, validation, and interaction
/// logic for a form field. It conforms to both `ValueEditor` and `Validatable` protocols,
/// providing a complete solution for form field management.
///
/// You typically use this class in conjunction with the `@PropertyEditor` macro within a
/// `@QuickForm`-annotated class.
///
/// ## Features
/// - Manages the field's value, title, and placeholder
/// - Handles read-only state
/// - Provides built-in validation support
/// - Allows for custom value change handling
///
/// ## Example
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.name)
///     var name = FormFieldViewModel(
///         value: "",
///         title: "Name:",
///         placeholder: "Enter your name",
///         validation: .combined(.notEmpty, .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.age)
///     var age = FormFieldViewModel(
///         value: 0,
///         title: "Age:",
///         validation: AnyValidationRule { value in
///             guard value >= 0 && value <= 120 else {
///                 return .failure("Age must be between 0 and 120")
///             }
///             return .success
///         }
///     )
/// }
/// ```
@Observable
public final class FormFieldViewModel<Property>: ObservableValueEditor, Validatable {
    /// The title of the form field.
    public var title: LocalizedStringResource
    /// An optional placeholder text for the form field.
    public var placeholder: LocalizedStringResource?
    /// The current value of the form field.
    public var value: Property {
        didSet {
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool

    private var dispatcher: Dispatcher
    private let validation: AnyValidationRule<Property>?
    private var validationResult: ValidationResult = .success
    /// Initializes a new instance of `FormFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial value of the form field.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    public init(
        value: Property,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property>? = nil
    ) {
        _value = value
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
    /// - Returns: The `FormFieldViewModel` instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
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
