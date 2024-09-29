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
public final class PickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ObservableValueEditor {
    /// The title of the picker field.
    public var title: LocalizedStringResource
    /// An array of all available values for the picker.
    public var allValues: [Property]
    /// The currently selected value.
    public var value: Property {
        didSet {
            dispatcher.publish(value)
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool

    private var dispatcher: Dispatcher
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
        dispatcher = Dispatcher()
    }

    /// Sets a closure to be called when the selected value changes.
    ///
    /// - Parameter change: A closure that takes the new selected value as its parameter.
    /// - Returns: The `PickerFieldViewModel` instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }
}
