// MultiPickerFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-02 09:51 GMT.

import Foundation
import Observation

/// A view model for managing a multi-selection form field with picker-style interaction.
///
/// `MultiPickerFieldViewModel` is a generic class that handles the data and interaction logic
/// for form fields where users need to select multiple items from a predefined set of options.
/// It maintains a set of selected values and provides mechanisms for tracking changes.
///
/// This class is primarily designed to be used with ``FormMultiPickerSection`` to create
/// multi-selection interfaces like checkboxes, tags, or multi-select lists.
///
/// ## Features
/// - Manages a set of selected values from available options
/// - Provides a list of all available options to choose from
/// - Handles read-only state for display-only scenarios
/// - Enables change tracking through an observer pattern
/// - Seamlessly integrates with ``FormMultiPickerSection`` for UI presentation
///
/// ## Example
///
/// ```swift
/// // Define your selectable items
/// enum Category: String, CaseIterable, CustomStringConvertible, Hashable {
///     case food, travel, entertainment, utilities, shopping
///
///     var description: String { rawValue.capitalized }
/// }
///
/// // Use in a form model
/// @QuickForm(Expense.self)
/// class ExpenseEditModel: Validatable {
///     @PropertyEditor(keyPath: \Expense.categories)
///     var categories = MultiPickerFieldViewModel(
///         value: [.food, .utilities],  // Initially selected categories
///         allValues: Category.allCases,
///         title: "Categories"
///     )
/// }
///
/// // Create the UI using FormMultiPickerSection
/// struct ExpenseCategoriesView: View {
///     @Bindable var model: ExpenseEditModel
///
///     var body: some View {
///         Form {
///             FormMultiPickerSection(model.categories)
///                 .onChange(of: model.categories.value) { oldValue, newValue in
///                     print("Selected categories changed to: \(newValue)")
///                 }
///         }
///     }
/// }
/// ```
@Observable
public final class MultiPickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ObservableValueEditor {
    /// The title of the picker field.
    ///
    /// This title is typically displayed as a section header or label
    /// when using ``FormMultiPickerSection``.
    public var title: LocalizedStringResource

    /// An array of all available values for selection.
    ///
    /// These values are presented as options in the UI, and the user
    /// can select any number of them to include in the `value` set.
    public var allValues: [Property]

    /// The current set of selected values.
    ///
    /// When this set changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - The UI will be updated to reflect the new selection state
    public var value: Set<Property> {
        didSet {
            if oldValue == value {
                return
            }
            dispatcher.publish(value)
        }
    }

    /// A boolean indicating whether the field is read-only.
    ///
    /// When `true`, the field should not allow user interaction or changes.
    /// UI components using this view model should respect this property and
    /// render the field in a read-only state.
    public var isReadOnly: Bool

    /// The dispatcher for value change notifications.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `MultiPickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial set of selected values.
    ///   - allValues: An array of all available values for selection.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a multi-picker for selecting days of week
    /// let weekdayPicker = MultiPickerFieldViewModel(
    ///     value: [.monday, .wednesday, .friday],  // Initially selected
    ///     allValues: DayOfWeek.allCases,
    ///     title: "Working Days"
    /// )
    /// ```
    public init(
        value: Set<Property>,
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

    /// Sets a closure to be called when the set of selected values changes.
    ///
    /// - Parameter change: A closure that takes the new set of selected values as its parameter.
    /// - Returns: A ``Subscription`` that can be used to unsubscribe when needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let subscription = categoryPicker.onValueChanged { selectedCategories in
    ///     // Update other dependent fields or perform actions
    ///     updateAvailableOptions(based: selectedCategories)
    /// }
    ///
    /// // Later, when no longer needed:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping (Set<Property>) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }
}

public extension MultiPickerFieldViewModel {
    /// Convenience initializer that starts with an empty selection set.
    ///
    /// - Parameters:
    ///   - type: The type of selectable items.
    ///   - allValues: An array of all available values for selection.
    ///   - includeDefaultValue: Unused parameter, kept for API compatibility.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a multi-picker with initially empty selection
    /// let tagPicker = MultiPickerFieldViewModel(
    ///     type: Tag.self,
    ///     allValues: availableTags,
    ///     title: "Select Tags"
    /// )
    ///
    /// // Then use it with a FormMultiPickerSection
    /// FormMultiPickerSection(tagPicker)
    /// ```
    convenience init(
        type: Property.Type,
        allValues: [Property],
        includeDefaultValue: Bool = false,
        title: LocalizedStringResource = "",
        isReadOnly: Bool = false
    ) {
        self.init(
            value: [],
            allValues: allValues,
            title: title,
            isReadOnly: isReadOnly
        )
    }
}
