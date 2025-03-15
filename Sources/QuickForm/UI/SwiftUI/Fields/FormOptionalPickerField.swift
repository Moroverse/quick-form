// FormOptionalPickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

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
///         type: Department.self,
///         allValues: Department.allCases,
///         title: "Department:",
///         validation: .of(.required())
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
    @State private var hasError: Bool
    private let pickerStyle: S
    let clearValueMode: ClearValueMode
    /// Initializes a new `FormOptionalPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
    public init(
        _ viewModel: OptionalPickerFieldViewModel<Property>,
        pickerStyle: S = .menu,
        clearValueMode: ClearValueMode = .never
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
        self.clearValueMode = clearValueMode
        hasError = viewModel.errorMessage != nil
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
                    if hasTitle {
                        Text(viewModel.title)
                            .font(.headline)
                    } else {
                        if shouldDisplayPlaceholder {
                            Text(viewModel.placeholder ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .pickerStyle(pickerStyle)
                .disabled(viewModel.isReadOnly)
                if shouldDisplayClearButton {
                    Button {
                        viewModel.value = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.borderless)
                }
            }

            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: viewModel.validationResult) { _, newValue in
            withAnimation {
                hasError = newValue != .success
            }
        }
    }

    private var shouldDisplayPlaceholder: Bool {
        if case .none = viewModel.value {
            hasPlaceholder
        } else {
            false
        }
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch clearValueMode {
        case .never:
            return false

        default:
            return viewModel.value != nil
        }
    }

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    private var hasPlaceholder: Bool {
        let value = String(localized: viewModel.placeholder ?? "")
        return value.isEmpty == false
    }
}
