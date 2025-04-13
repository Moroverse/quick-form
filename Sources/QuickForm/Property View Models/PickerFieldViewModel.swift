// PickerFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-02 09:51 GMT.

import Foundation
import Observation

/// A view model for managing a form field with a picker-style selection.
///
/// `PickerFieldViewModel` is a generic class that handles the data and interaction logic
/// for a form field that presents a set of options to choose from. It conforms to the
/// ``ObservableValueEditor`` protocol, providing a solution for picker-based form field management.
///
/// This class is particularly useful for fields where the user needs to select from a
/// predefined set of options, such as categories, types, or any enumerable values.
/// It's designed to work seamlessly with ``FormPickerField`` for UI representation.
///
/// ## Features
/// - Manages the field's selected value and title
/// - Provides a list of all available options
/// - Handles read-only state
/// - Allows for custom value change handling
/// - Integrates with SwiftUI form components
///
/// ## Example
///
/// ### Basic Usage
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
///         type: Category.self,
///         allValues: Category.allCases,
///         title: "Category:"
///     )
/// }
/// ```
///
/// ### Using with FormPickerField in SwiftUI
///
/// ```swift
/// struct ExpenseFormView: View {
///     @Bindable var model: ExpenseEditModel
///
///     var body: some View {
///         Form {
///             // Basic picker with default wheel style
///             FormPickerField(model.category)
///
///             // Picker with menu style
///             FormPickerField(model.category, pickerStyle: .menu)
///
///             // Picker with segmented style for few options
///             FormPickerField(model.category, pickerStyle: .segmented)
///         }
///     }
/// }
/// ```
///
/// ### Handling Value Changes
///
/// ```swift
/// // Subscribe to value changes
/// let subscription = category.onValueChanged { newCategory in
///     // Update dependent fields or perform actions
///     if newCategory == .travel {
///         transportType.isReadOnly = false
///     } else {
///         transportType.isReadOnly = true
///     }
/// }
///
/// // Later, when no longer needed:
/// subscription.unsubscribe()
/// ```
///
/// - SeeAlso: ``FormPickerField``, ``ObservableValueEditor``, ``Dispatcher``
@Observable
public final class PickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ObservableValueEditor {
    /// The title of the picker field.
    ///
    /// This title is typically displayed as a label for the picker field
    /// when used with ``FormPickerField`` or similar UI components.
    public var title: LocalizedStringResource

    /// An array of all available values for the picker.
    ///
    /// These values represent the complete set of options that can be selected
    /// in the picker. The array can be updated dynamically if needed to reflect
    /// changing available options.
    public var allValues: [Property]

    /// The currently selected value.
    ///
    /// When this value changes, all subscribers registered via `onValueChanged(_:)`
    /// are notified of the change.
    public var value: Property {
        didSet {
            dispatcher.publish(value)
        }
    }

    /// A boolean indicating whether the field is read-only.
    ///
    /// When `true`, the field should not allow user interaction or changes.
    /// UI components using this view model should respect this property and
    /// render the field in a read-only state.
    public var isReadOnly: Bool

    /// The dispatcher used for change notification.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `PickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a picker for selecting a priority level
    /// enum Priority: Int, CaseIterable, CustomStringConvertible {
    ///     case low = 1, medium, high
    ///
    ///     var description: String {
    ///         switch self {
    ///         case .low: return "Low"
    ///         case .medium: return "Medium"
    ///         case .high: return "High"
    ///         }
    ///     }
    /// }
    ///
    /// let priorityPicker = PickerFieldViewModel(
    ///     value: Priority.medium,
    ///     allValues: Priority.allCases,
    ///     title: "Priority:"
    /// )
    /// ```
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
        dispatcher = Dispatcher()
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
    /// // Update description field based on category selection
    /// let subscription = categoryPicker.onValueChanged { newCategory in
    ///     switch newCategory {
    ///     case .food:
    ///         descriptionField.placeholder = "What did you eat?"
    ///     case .travel:
    ///         descriptionField.placeholder = "Where did you go?"
    ///     case .entertainment:
    ///         descriptionField.placeholder = "What did you do?"
    ///     }
    /// }
    ///
    /// // Later, when no longer needed:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }
}

/// Extension providing convenience initializers for types that conform to ``DefaultValueProvider``.
public extension PickerFieldViewModel where Property: DefaultValueProvider {
    /// Convenience initializer that uses the default value of the property type.
    ///
    /// This initializer allows you to specify the type of property instead of providing
    /// an explicit initial value. The default value is obtained from the type's implementation
    /// of ``DefaultValueProvider``.
    ///
    /// - Parameters:
    ///   - type: The type of property.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Using with enums that implement DefaultValueProvider
    /// enum PaymentMethod: String, CaseIterable, CustomStringConvertible, DefaultValueProvider {
    ///     case creditCard, bankTransfer, cash, applePay
    ///
    ///     var description: String { rawValue.capitalized }
    ///
    ///     static var defaultValue: PaymentMethod { .creditCard }
    /// }
    ///
    /// let paymentPicker = PickerFieldViewModel(
    ///     type: PaymentMethod.self,
    ///     allValues: PaymentMethod.allCases,
    ///     title: "Payment Method:"
    /// )
    /// ```
    ///
    /// - SeeAlso: ``DefaultValueProvider``
    convenience init(
        type: Property.Type,
        allValues: [Property],
        title: LocalizedStringResource = "",
        isReadOnly: Bool = false
    ) {
        self.init(
            value: Property.defaultValue,
            allValues: allValues,
            title: title,
            isReadOnly: isReadOnly
        )
    }
}
