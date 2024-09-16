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
            if hasTitle {
                Text(viewModel.title)
                    .font(.headline)
            }
        }
        .pickerStyle(pickerStyle)
        .disabled(viewModel.isReadOnly)
    }

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }
}

#Preview {
    @Previewable @State var viewModel = PickerFieldViewModel(value: 1, allValues: [0, 1, 2, 3])
    Form {
        FormPickerField(viewModel)
    }
}
