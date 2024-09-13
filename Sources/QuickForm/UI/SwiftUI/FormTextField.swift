// FormTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

public struct FormTextField: View {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @Bindable private var viewModel: FormFieldViewModel<String>

    public init(_ viewModel: FormFieldViewModel<String>) {
        self.viewModel = viewModel
        isFocused = false
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Text(viewModel.title)
                    .font(.headline)
                TextField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value)
                    .focused($isFocused)
                    .multilineTextAlignment(alignment)
                    .disabled(viewModel.isReadOnly)
            }
            if !viewModel.isValid {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }.onChange(of: isFocused) {
            withAnimation {
                alignment = isFocused ? .leading : .trailing
            }
        }
    }
}

/// A SwiftUI view that represents an optional text field in a form.
///
/// `FormOptionalTextField` is designed to work with optional string values in forms.
/// It provides a text field that can be empty (representing `nil`) or contain a string value.
/// The view includes built-in support for titles, placeholders, and validation feedback.
///
/// This view is typically used in conjunction with a `FormFieldViewModel<String?>` to manage its state.
///
/// ## Features
/// - Handles optional string values
/// - Displays a title for the field
/// - Supports placeholder text
/// - Shows validation error messages
/// - Adapts its text alignment based on focus state
/// - Supports read-only mode
///
/// ## Example
///
/// ```swift
/// struct PersonForm: View {
///     @State private var viewModel = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Middle Name:",
///         placeholder: "Enter middle name (optional)"
///     )
///
///     var body: some View {
///         Form {
///             FormOptionalTextField(viewModel)
///         }
///     }
/// }
/// ```
public struct FormOptionalTextField: View {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @Bindable private var viewModel: FormFieldViewModel<String?>

    /// Initializes a new `FormOptionalTextField`.
    ///
    /// - Parameter viewModel: The view model that manages the state of this text field.
    public init(_ viewModel: FormFieldViewModel<String?>) {
        self.viewModel = viewModel
        isFocused = false
    }

    /// The body of the `FormOptionalTextField` view.
    ///
    /// This view consists of:
    /// - A title label
    /// - An optional text field
    /// - An error message (if validation fails)
    ///
    /// The text field's alignment changes based on whether it's focused or not.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Text(viewModel.title)
                    .font(.headline)
                TextField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value.unwrapped(defaultValue: ""))
                    .focused($isFocused)
                    .multilineTextAlignment(alignment)
                    .disabled(viewModel.isReadOnly)
            }
            if !viewModel.isValid {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isFocused) {
            alignment = isFocused ? .leading : .trailing
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "Name",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextField(viewModel)
    }
}
