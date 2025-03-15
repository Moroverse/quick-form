// OptionalPickerFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-02 09:51 GMT.

import Foundation
import Observation

/// A view model for managing a form field with an optional picker-style selection.
///
/// `OptionalPickerFieldViewModel` is a generic class that handles the data, validation, and interaction logic
/// for a form field that presents a set of options to choose from, including the option to have no selection.
/// It conforms to both `ValueEditor` and `Validatable` protocols, providing a complete solution for
/// optional picker-based form field management.
///
/// This class is particularly useful for fields where the user can select from a predefined set of options
/// or choose to have no selection at all.
///
/// ## Features
/// - Manages the field's selected value (which can be nil) and title
/// - Provides a list of all available options
/// - Handles read-only state
/// - Supports validation of the optional selection
/// - Provides validation error messages
///
/// ## Example
///
/// ```swift
/// enum Department: String, CaseIterable, CustomStringConvertible {
///     case sales, engineering, marketing
///     var description: String { rawValue.capitalized }
/// }
///
/// @QuickForm(Employee.self)
/// class EmployeeEditModel: Validatable {
///     @PropertyEditor(keyPath: \Employee.department)
///     var department = OptionalPickerFieldViewModel(
///         value: nil,
///         allValues: Department.allCases,
///         title: "Department:",
///         validation: AnyValidationRule { value in
///             guard value != nil else {
///                 return .failure("Department must be selected")
///             }
///             return .success
///         }
///     )
/// }
/// ```
@Observable
public final class OptionalPickerFieldViewModel<Property: Hashable & CustomStringConvertible>:
    ObservableValueEditor, Validatable {
    /// The title of the picker field.
    public var title: LocalizedStringResource
    /// An optional placeholder text for the form field.
    public var placeholder: LocalizedStringResource?
    /// An array of all available values for the picker.
    public var allValues: [Property]
    /// The currently selected value, which can be nil.
    public var value: Property? {
        didSet {
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool
    /// The validation rule to apply to the selected value.
    public var validation: AnyValidationRule<Property?>?

    private(set) var validationResult: ValidationResult = .success
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `OptionalPickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value, which can be nil.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    public init(
        value: Property?,
        allValues: [Property],
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property?>? = nil
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        dispatcher = Dispatcher()
        validationResult = validate()
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }

    /// Sets a closure to be called when the selected value changes.
    ///
    /// - Parameter change: A closure that takes the new selected value as its parameter.
    /// - Returns: The `OptionalPickerFieldViewModel` instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property?) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }
}

public extension OptionalPickerFieldViewModel where Property: DefaultValueProvider {
    convenience init(
        type: Property?.Type,
        allValues: [Property],
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property?>? = nil
    ) {
        self.init(
            value: Property.defaultValue,
            allValues: allValues,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation
        )
    }
}
