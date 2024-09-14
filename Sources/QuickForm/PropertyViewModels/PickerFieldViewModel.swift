// PickerFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import Observation

/// A view model for managing a form field with a picker-style selection.
///
/// `PickerFieldViewModel` is a generic class that handles the data and interaction logic
/// for a form field that presents a set of options to choose from. It conforms to the
/// `ValueEditor` protocol, providing a solution for picker-based form field management.
///
/// This class is particularly useful for fields where the user needs to select from a
/// predefined set of options, such as categories, types, or any enumerable values.
///
/// ## Features
/// - Manages the field's selected value and title
/// - Provides a list of all available options
/// - Handles read-only state
/// - Allows for custom value change handling
///
/// ## Example
///
/// ```swift
/// enum Category: String, CaseIterable, CustomStringConvertible {
///     case food, travel, entertainment
///
///     var description: String { rawValue.capitalized }
/// }
///
/// @QuickForm(Expense.self)
/// class ExpenseEditModel: Validatable {
///     @PropertyEditor(keyPath: \Expense.category)
///     var category = PickerFieldViewModel(
///         value: Category.food,
///         allValues: Category.allCases,
///         title: "Category:"
///     )
/// }
/// ```
@Observable
public final class PickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ValueEditor {
    /// The title of the picker field.
    public var title: LocalizedStringResource
    /// An array of all available values for the picker.
    public var allValues: [Property]
    /// The currently selected value.
    public var value: Property {
        didSet {
            valueChanged?(value)
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool

    private var valueChanged: ((Property) -> Void)?
    /// Initializes a new instance of `PickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    public init(
        value: Property,
        allValues: [Property],
        title: LocalizedStringResource = "",
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.isReadOnly = isReadOnly
    }

    /// Sets a closure to be called when the selected value changes.
    ///
    /// - Parameter change: A closure that takes the new selected value as its parameter.
    /// - Returns: The `PickerFieldViewModel` instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
        valueChanged = change
        return self
    }
}

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
    ValueEditor, Validatable {
    /// The title of the picker field.
    public var title: String
    /// An array of all available values for the picker.
    public var allValues: [Property]
    /// The currently selected value, which can be nil.
    public var value: Property? {
        didSet {
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool
    public var clearValueMode: ClearValueMode
    /// The validation rule to apply to the selected value.
    public var validation: AnyValidationRule<Property?>?

    private var validationResult: ValidationResult = .success

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
        title: String = "",
        isReadOnly: Bool = false,
        clearValueMode: ClearValueMode = .never,
        validation: AnyValidationRule<Property?>? = nil
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.isReadOnly = isReadOnly
        self.clearValueMode = clearValueMode
        self.validation = validation
        validationResult = validate()
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }
}
