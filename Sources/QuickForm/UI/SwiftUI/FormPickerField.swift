// FormPickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

/// A SwiftUI view that represents a picker field in a form.
///
/// `FormPickerField` is designed to work with `PickerFieldViewModel` to provide
/// a picker interface for selecting values from a predefined set of options.
/// It's particularly useful for fields where the user needs to choose from a list
/// of items, such as categories, types, or any enumerable values.
///
/// ## Features
/// - Displays a picker with a title
/// - Supports customizable picker styles
/// - Works with any `Hashable` and `CustomStringConvertible` value types
/// - Can be set to read-only mode
/// - Automatically updates the underlying value when a selection is made
///
/// ## Example
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
public struct FormPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: PickerFieldViewModel<Property>
    private let pickerStyle: S

    /// Initializes a new `FormPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
    public init(
        _ viewModel: PickerFieldViewModel<Property>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    public var body: some View {
        Picker(selection: $viewModel.value) {
            ForEach(viewModel.allValues, id: \.self) { itemCase in
                Text(itemCase.description)
            }
        } label: {
            Text(viewModel.title)
                .font(.headline)
        }
        .pickerStyle(pickerStyle)
        .fixedSize()
        .disabled(viewModel.isReadOnly)
    }
}

/// A SwiftUI view that represents an optional picker field in a form.
///
/// `FormOptionalPickerField` is designed to work with optional values in forms where the user
/// can select from a list of options or choose none. It provides a picker interface that can
/// have no selection (representing `nil`) or a selected value from the provided options.
///
/// This view is typically used in conjunction with an `OptionalPickerFieldViewModel<Property>`
/// to manage its state.
///
/// ## Features
/// - Handles optional values of any `Hashable` and `CustomStringConvertible` type
/// - Displays a title for the field
/// - Supports customizable picker styles
/// - Shows validation error messages
/// - Supports read-only mode
///
/// ## Example
///
/// ```swift
/// enum Department: String, CaseIterable, CustomStringConvertible {
///     case sales, engineering, marketing, none
///     var description: String { rawValue.capitalized }
/// }
///
/// struct EmployeeForm: View {
///     @State private var viewModel = OptionalPickerFieldViewModel<Department>(
///         value: nil,
///         allValues: Department.allCases,
///         title: "Department:",
///         validation: .of(RequiredRule())
///     )
///
///     var body: some View {
///         Form {
///             FormOptionalPickerField(viewModel)
///         }
///     }
/// }
/// ```
public struct FormOptionalPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: OptionalPickerFieldViewModel<Property>
    private let pickerStyle: S
    /// Initializes a new `FormOptionalPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
    public init(
        _ viewModel: OptionalPickerFieldViewModel<Property>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    /// The body of the `FormOptionalPickerField` view.
    ///
    /// This view consists of:
    /// - A picker with an optional "None" choice and all provided values
    /// - An error message (if validation fails)
    ///
    /// The picker's style can be customized through the `pickerStyle` parameter in the initializer.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Picker(selection: $viewModel.value) {
                    Text("None")
                        .tag(Property?.none)
                    ForEach(viewModel.allValues, id: \.self) { itemCase in
                        Text(itemCase.description)
                            .tag(Optional(itemCase))
                    }
                } label: {
                    Text(viewModel.title)
                        .font(.headline)
                }
                .pickerStyle(pickerStyle)
                .fixedSize()
                .disabled(viewModel.isReadOnly)
                if shouldDisplayClearButton {
                    Button {
                        viewModel.value = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.borderless)
                }
            }
            if !viewModel.isValid {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch viewModel.clearValueMode {
        case .never:
            return false
        default:
            return true
        }
    }
}

#Preview {
    @Previewable @State var viewModel = PickerFieldViewModel(value: 1, allValues: [0, 1, 2, 3])
    Form {
        FormPickerField(viewModel)
    }
}
