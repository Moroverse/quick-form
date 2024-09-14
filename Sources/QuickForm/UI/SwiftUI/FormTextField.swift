// FormTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

extension ValueAlignment {
    var textAlignment: TextAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

public struct FormTextField: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool

    public init(_ viewModel: FormFieldViewModel<String>) {
        self.viewModel = viewModel
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = viewModel.alignment.textAlignment
        isFocused = false
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                if hasTitle {
                    Text(viewModel.title)
                        .font(.headline)
                }
                TextField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value)
                    .focused($isFocused)
                    .multilineTextAlignment(resolvedAlignment)
                    .disabled(viewModel.isReadOnly)
            }
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isFocused) {
            if viewModel.alignment != .leading {
                withAnimation {
                    resolvedAlignment = isFocused ? .leading : viewModel.alignment.textAlignment
                }
            }
        }
        .onChange(of: viewModel.alignment) {
            if !isFocused {
                withAnimation {
                    resolvedAlignment = viewModel.alignment.textAlignment
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
                viewModel.value = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch viewModel.clearValueMode {
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

    /// Initializes a new `FormOptionalTextField`.
    ///
    /// - Parameter viewModel: The view model that manages the state of this text field.
    public init(_ viewModel: FormFieldViewModel<String?>) {
        self.viewModel = viewModel
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = viewModel.alignment.textAlignment
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
                TextField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value.unwrapped(defaultValue: ""))
                    .focused($isFocused)
                    .multilineTextAlignment(resolvedAlignment)
                    .disabled(viewModel.isReadOnly)
            }
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isFocused) {
            if viewModel.alignment != .leading {
                withAnimation {
                    resolvedAlignment = isFocused ? .leading : viewModel.alignment.textAlignment
                }
            }
        }
        .onChange(of: viewModel.alignment) {
            if !isFocused {
                withAnimation {
                    resolvedAlignment = viewModel.alignment.textAlignment
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
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch viewModel.clearValueMode {
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

#Preview("Default") {
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

#Preview("Alignment") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "Name",
        placeholder: "John",
        isReadOnly: false,
        alignment: .leading
    )

    Form {
        FormTextField(viewModel)
    }
}

#Preview("Not Title") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "",
        placeholder: "John",
        isReadOnly: false,
        alignment: .leading
    )

    Form {
        FormTextField(viewModel)
    }
}
