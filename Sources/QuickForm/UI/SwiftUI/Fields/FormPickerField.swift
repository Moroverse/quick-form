// FormPickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

/// A SwiftUI view that represents a picker field in a form.
///
/// `FormPickerField` is designed to work with ``PickerFieldViewModel`` to provide
/// a picker interface for selecting values from a predefined set of options.
/// It's particularly useful for fields where the user needs to choose from a list
/// of items, such as categories, types, or any enumerable values.
///
/// ## Features
/// - Displays a picker with a title
/// - Supports customizable picker styles (menu, wheel, segmented, etc.)
/// - Works with any `Hashable` and `CustomStringConvertible` value types
/// - Can be set to read-only mode
/// - Automatically updates the underlying value when a selection is made
/// - Integrates with form validation systems
///
/// ## Examples
///
/// ### Basic Usage with Enums
///
/// ```swift
/// enum Category: String, CaseIterable, CustomStringConvertible {
///     case food, travel, entertainment
///     var description: String { rawValue.capitalized }
/// }
///
/// struct ExpenseForm: View {
///     @State private var viewModel = PickerFieldViewModel(
///         value: Category.food,
///         allValues: Category.allCases,
///         title: "Category:"
///     )
///
///     var body: some View {
///         Form {
///             FormPickerField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### Different Picker Styles
///
/// ```swift
/// // Menu style picker (default)
/// FormPickerField(viewModel)
///
/// // Wheel style picker (good for iOS)
/// FormPickerField(viewModel, pickerStyle: .wheel)
///
/// // Segmented style picker (good for few options)
/// FormPickerField(viewModel, pickerStyle: .segmented)
/// ```
///
/// ### Integration with QuickForm Models
///
/// ```swift
/// @QuickForm(Expense.self)
/// class ExpenseFormModel: Validatable {
///     @PropertyEditor(keyPath: \Expense.category)
///     var category = PickerFieldViewModel(
///         value: Category.food,
///         allValues: Category.allCases,
///         title: "Category:",
///         validation: .of(.required("Please select a category"))
///     )
///
///     @PropertyEditor(keyPath: \Expense.priority)
///     var priority = PickerFieldViewModel(
///         value: Priority.medium,
///         allValues: Priority.allCases,
///         title: "Priority:"
///     )
/// }
///
/// struct ExpenseEditView: View {
///     @Bindable var model: ExpenseFormModel
///
///     var body: some View {
///         Form {
///             FormPickerField(model.category)
///                 .validationState(model.category.validationResult)
///
///             FormPickerField(model.priority, pickerStyle: .segmented)
///         }
///     }
/// }
/// ```
///
/// ### Working with Custom Types
///
/// ```swift
/// struct Department: Hashable, CustomStringConvertible {
///     let id: UUID
///     let name: String
///     let code: String
///
///     var description: String { name }
/// }
///
/// struct EmployeeForm: View {
///     @State private var departments = [
///         Department(id: UUID(), name: "Engineering", code: "ENG"),
///         Department(id: UUID(), name: "Marketing", code: "MKT"),
///         Department(id: UUID(), name: "Human Resources", code: "HR")
///     ]
///
///     @State private var viewModel = PickerFieldViewModel(
///         value: nil,
///         allValues: [],
///         title: "Department:"
///     )
///
///     var body: some View {
///         Form {
///             FormPickerField(viewModel)
///                 .onAppear {
///                     // Update available choices when view appears
///                     viewModel.allValues = departments
///                     if departments.count > 0 {
///                         viewModel.value = departments[0]
///                     }
///                 }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``PickerFieldViewModel``, ``FormOptionalPickerField``, ``FormMultiPickerSection``
public struct FormPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: PickerFieldViewModel<Property>
    private let pickerStyle: S

    /// Initializes a new `FormPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``PickerFieldViewModel`` that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic usage with menu style (default)
    /// FormPickerField(categoryViewModel)
    ///
    /// // Wheel style for iOS interfaces
    /// FormPickerField(dateViewModel, pickerStyle: .wheel)
    ///
    /// // Segmented control for short lists
    /// FormPickerField(
    ///     priorityViewModel,
    ///     pickerStyle: .segmented
    /// )
    /// ```
    public init(
        _ viewModel: PickerFieldViewModel<Property>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    /// The body of the `FormPickerField` view.
    ///
    /// This view consists of:
    /// - A picker with all available values from the view model
    /// - An optional title label when a title is provided
    ///
    /// The picker's style is determined by the `pickerStyle` parameter provided in the initializer.
    /// When the view model's `isReadOnly` property is true, the picker is disabled.
    public var body: some View {
        Picker(selection: $viewModel.value) {
            ForEach(viewModel.allValues, id: \.self) { itemCase in
                Text(itemCase.description)
            }
        } label: {
            if hasTitle {
                Text(viewModel.title)
                    .font(.headline)
            }
        }
        .pickerStyle(pickerStyle)
        .disabled(viewModel.isReadOnly)
    }

    /// Checks if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }
}

#Preview("Basic") {
    @Previewable @State var viewModel = PickerFieldViewModel(value: 1, allValues: [0, 1, 2, 3])
    Form {
        FormPickerField(viewModel)
    }
}

#Preview("With Title") {
    @Previewable @State var viewModel = PickerFieldViewModel(
        value: "Apple",
        allValues: ["Apple", "Banana", "Orange"],
        title: "Fruit"
    )
    Form {
        FormPickerField(viewModel)
    }
}

enum Priority: String, CaseIterable, CustomStringConvertible, Hashable {
    case low, medium, high
    var description: String { rawValue.capitalized }
}

#Preview("Segmented") {
    @Previewable @State var viewModel = PickerFieldViewModel(
        value: Priority.medium,
        allValues: Priority.allCases,
        title: "Priority"
    )

    Form {
        FormPickerField(viewModel, pickerStyle: .segmented)
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = PickerFieldViewModel(
        value: "Confirmed",
        allValues: ["Pending", "Confirmed", "Canceled"],
        title: "Status",
        isReadOnly: true
    )

    Form {
        FormPickerField(viewModel)
    }
}
