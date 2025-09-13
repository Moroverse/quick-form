// OptionalPickerFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation

/// A view model for managing a form field with an optional picker-style selection.
///
/// `OptionalPickerFieldViewModel` is a generic class that handles the data, validation, and interaction logic
/// for a form field that presents a set of options to choose from, including the option to have no selection.
/// It conforms to both ``ObservableValueEditor`` and ``Validatable`` protocols, providing a complete solution for
/// optional picker-based form field management.
///
/// This class is particularly useful for fields where the user can select from a predefined set of options
/// or choose to have no selection at all, and is designed to work seamlessly with ``FormOptionalPickerField``.
///
/// ## Features
/// - Manages the field's selected value (which can be nil) and title
/// - Provides a list of all available options
/// - Handles read-only state
/// - Supports validation of the optional selection
/// - Provides validation error messages
///
/// ## Examples
///
/// ### Basic Usage
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
///         validation: .of(.required("Department must be selected"))
///     )
/// }
/// ```
///
/// ### Using with FormOptionalPickerField
///
/// ```swift
/// struct EmployeeFormView: View {
///     @Bindable var model: EmployeeEditModel
///
///     var body: some View {
///         Form {
///             // Basic usage with default style
///             FormOptionalPickerField(model.department)
///
///             // With custom style and clear button
///             FormOptionalPickerField(
///                 model.department,
///                 clearValueMode: .always,
///                 pickerStyle: .menu
///             )
///
///             // With validation feedback
///             FormOptionalPickerField(model.department)
///                 .validationState(model.department.validationResult)
///         }
///     }
/// }
/// ```
///
/// ### Handling Value Changes
///
/// ```swift
/// // In your initialization code:
/// init() {
///     // Subscribe to value changes
///     department.onValueChanged { newDepartment in
///         if newDepartment == .engineering {
///             // Update other dependent fields
///             self.team.allValues = EngineeringTeam.allCases
///             self.team.value = nil
///         } else if newDepartment == .sales {
///             self.team.allValues = SalesTeam.allCases
///             self.team.value = nil
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormOptionalPickerField``, ``ObservableValueEditor``, ``Validatable``
@Observable
public final class OptionalPickerFieldViewModel<Property: Hashable & CustomStringConvertible>:
    ObservableValueEditor, Validatable {
    /// The title of the picker field.
    ///
    /// This title is typically displayed as a label for the picker field
    /// or as part of the selection UI in `FormOptionalPickerField`.
    public var title: LocalizedStringResource

    /// An optional placeholder text for the form field.
    ///
    /// This text is displayed when no value is selected, providing guidance
    /// to the user about what kind of selection is expected.
    public var placeholder: LocalizedStringResource?

    /// An array of all available values for the picker.
    ///
    /// These values represent the complete set of options that can be selected
    /// in the picker. The array can be updated dynamically if needed to reflect
    /// changing available options.
    public var allValues: [Property]

    /// The currently selected value, which can be nil.
    ///
    /// When this value changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - Validation is performed and `validationResult` is updated
    public var value: Property? {
        didSet {
            if oldValue == value {
                return
            }
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    ///
    /// When `true`, the field should not allow user interaction or changes.
    /// UI components using this view model should respect this property and
    /// render the field in a read-only state.
    public var isReadOnly: Bool

    /// The validation rule to apply to the selected value.
    ///
    /// This rule is evaluated whenever the `value` property changes or when
    /// `validate()` is called explicitly.
    public var validation: AnyValidationRule<Property?>?

    /// The current validation state of the field.
    ///
    /// This property reflects whether the current value of the field
    /// satisfies the validation rules. It's updated automatically when
    /// the value changes.
    private(set) var validationResult: ValidationResult = .success

    /// The dispatcher used for change notification.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `OptionalPickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value, which can be nil.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a model for selecting an optional priority
    /// enum Priority: Int, CaseIterable, CustomStringConvertible {
    ///     case low = 1, medium, high
    ///     var description: String {
    ///         switch self {
    ///         case .low: "Low"
    ///         case .medium: "Medium"
    ///         case .high: "High"
    ///         }
    ///     }
    /// }
    ///
    /// let priorityPicker = OptionalPickerFieldViewModel(
    ///     value: nil, // No priority selected initially
    ///     allValues: Priority.allCases,
    ///     title: "Priority:",
    ///     placeholder: "Select a priority level",
    ///     validation: .of(.required("Please select a priority"))
    /// )
    /// ```
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
    /// This method evaluates the field's value against the validation rule
    /// provided during initialization. If no validation rule was provided,
    /// it returns `.success`.
    ///
    /// - Returns: A ``ValidationResult`` indicating whether validation succeeded or failed.
    ///
    /// - SeeAlso: ``ValidationResult``, ``AnyValidationRule``
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }

    /// Sets a closure to be called when the selected value changes.
    ///
    /// This method allows you to register a callback that will be invoked
    /// whenever the field's value changes. It's useful for implementing dependencies
    /// between fields or updating UI state based on selection changes.
    ///
    /// - Parameter change: A closure that takes the new selected value as its parameter.
    /// - Returns: A ``Subscription`` object that can be used to unsubscribe when needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Update job title options when department changes
    /// let subscription = departmentPicker.onValueChanged { newDepartment in
    ///     if let dept = newDepartment {
    ///         // Update job title options based on selected department
    ///         jobTitlePicker.allValues = getJobTitles(for: dept)
    ///         jobTitlePicker.value = nil  // Clear current selection
    ///     } else {
    ///         // No department selected, show default titles
    ///         jobTitlePicker.allValues = defaultJobTitles
    ///         jobTitlePicker.value = nil
    ///     }
    /// }
    ///
    /// // Later, when no longer needed:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property?) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }
}

/// Extension providing convenience initializers for types that conform to ``DefaultValueProvider``.
public extension OptionalPickerFieldViewModel where Property: DefaultValueProvider {
    /// Convenience initializer that uses the default value of the property type.
    ///
    /// This initializer allows you to specify the type of property instead of providing
    /// an explicit initial value. The default value is obtained from the type's implementation
    /// of ``DefaultValueProvider``.
    ///
    /// - Parameters:
    ///   - type: The type of property. Using `Property?.self` signals that this is an optional property.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Using with enums that implement DefaultValueProvider
    /// enum Category: String, CaseIterable, CustomStringConvertible, DefaultValueProvider {
    ///     case groceries, utilities, entertainment, travel
    ///
    ///     var description: String { rawValue.capitalized }
    ///
    ///     static var defaultValue: Category { .groceries }
    /// }
    ///
    /// let categoryPicker = OptionalPickerFieldViewModel(
    ///     type: Category?.self,  // Specify optional type
    ///     allValues: Category.allCases,
    ///     title: "Category",
    ///     placeholder: "Select expense category"
    /// )
    /// ```
    ///
    /// - SeeAlso: ``DefaultValueProvider``
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
