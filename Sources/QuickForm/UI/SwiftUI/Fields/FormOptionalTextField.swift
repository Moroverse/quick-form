// FormOptionalTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

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
    @Bindable private var viewModel: FormFieldViewModel<String?>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode
    let autocapitalizationType: TextInputAutocapitalization

    /// Initializes a new `FormOptionalTextField`.
    ///
    /// - Parameter viewModel: The view model that manages the state of this text field.
    public init(
        _ viewModel: FormFieldViewModel<String?>,
        alignment: TextAlignment = .trailing,
        clearValueMode: ClearValueMode = .never,
        autocapitalizationType: TextInputAutocapitalization = .never
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        self.autocapitalizationType = autocapitalizationType
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
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
                if hasTitle {
                    Text(viewModel.title)
                        .font(.headline)
                }
                TextField(
                    String(
                        localized: viewModel.placeholder ?? ""
                    ),
                    text: $viewModel.value.unwrapped(defaultValue: "")
                )
                .textInputAutocapitalization(autocapitalizationType)
                .focused($isFocused)
                .multilineTextAlignment(resolvedAlignment)
                .disabled(viewModel.isReadOnly)
                .onSubmit {
                    isFocused = false
                }
            }
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isFocused) {
            if alignment != .leading {
                withAnimation {
                    resolvedAlignment = isFocused ? .leading : alignment
                }
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            withAnimation {
                hasError = newValue != nil
            }
        }

        if shouldDisplayClearButton {
            Button {
                viewModel.value = nil
            } label: {
                Image(systemName: "xmark.circle")
            }
            .buttonStyle(.borderless)
        }
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch clearValueMode {
        case .never:
            return false

        case .whileEditing:
            return isFocused == true

        case .unlessEditing:
            return isFocused == false

        case .always:
            return true
        }
    }

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }
}
