// FormSecureTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-15 05:19 GMT.

import SwiftUI

/// A SwiftUI view that represents a secure text field in a form.
///
/// `FormSecureTextField` is designed to work with ``FormFieldViewModel<String>`` to provide
/// a secure text input field for entering sensitive information like passwords. The component
/// obscures the input text and provides standard form field features like validation feedback,
/// titles, and optional clear buttons.
///
/// ## Features
/// - Displays a secure text field with masked input
/// - Supports customizable text alignment
/// - Shows validation error messages when validation fails
/// - Provides configurable clear button functionality
/// - Dynamically adjusts text alignment based on focus state
/// - Supports read-only mode for displaying (but not editing) password fields
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct LoginForm: View {
///     @State private var passwordModel = FormFieldViewModel(
///         value: "",
///         title: "Password:",
///         placeholder: "Enter your password",
///         validation: .of(.required("Password is required"))
///     )
///
///     var body: some View {
///         Form {
///             FormSecureTextField(passwordModel)
///         }
///     }
/// }
/// ```
///
/// ### With Password Validation
///
/// ```swift
/// @QuickForm(LoginCredentials.self)
/// class LoginFormModel: Validatable {
///     @PropertyEditor(keyPath: \LoginCredentials.password)
///     var password = FormFieldViewModel(
///         value: "",
///         title: "Password",
///         placeholder: "Enter password",
///         validation: .of(.composite([
///             .required("Password is required"),
///             .minLength(8, "Password must be at least 8 characters"),
///             .pattern("[A-Z]", "Password must contain at least one uppercase letter"),
///             .pattern("[0-9]", "Password must contain at least one number")
///         ]))
///     )
/// }
///
/// struct LoginFormView: View {
///     @Bindable var model: LoginFormModel
///
///     var body: some View {
///         Form {
///             FormSecureTextField(model.password, clearValueMode: .whileEditing)
///                 .validationState(model.password.validationResult)
///         }
///     }
/// }
/// ```
///
/// ### Customized Alignment and Clear Button
///
/// ```swift
/// // Left-aligned with always visible clear button
/// FormSecureTextField(
///     passwordViewModel,
///     alignment: .leading,
///     clearValueMode: .always
/// )
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormTextField``, ``ClearValueMode``, ``ValidationResult``
public struct FormSecureTextField: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode

    /// Initializes a new `FormSecureTextField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this secure text field.
    ///   - alignment: The text alignment to use when the field is not focused. Defaults to `.trailing`.
    ///     When the field gains focus, alignment temporarily changes to `.leading` for easier editing.
    ///   - clearValueMode: Controls when the clear button appears. Defaults to `.never`.
    ///     - `.never`: Never show a clear button
    ///     - `.always`: Always show a clear button when the field has content
    ///     - `.whileEditing`: Show a clear button only when the field is focused
    ///     - `.unlessEditing`: Show a clear button except when the field is focused
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic secure field with default settings
    /// FormSecureTextField(passwordViewModel)
    ///
    /// // Secure field with custom alignment and clear button behavior
    /// FormSecureTextField(
    ///     passwordViewModel,
    ///     alignment: .leading,
    ///     clearValueMode: .whileEditing
    /// )
    /// ```
    public init(
        _ viewModel: FormFieldViewModel<String>,
        alignment: TextAlignment = .trailing,
        clearValueMode: ClearValueMode = .never
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
        isFocused = false
    }

    /// The body of the `FormSecureTextField` view.
    ///
    /// This view consists of:
    /// - A title label (when provided)
    /// - A secure text field that masks input characters
    /// - An optional clear button (when enabled by `clearValueMode`)
    /// - An error message when validation fails
    ///
    /// The text field's alignment changes based on whether it's focused or not,
    /// making it easier for users to edit the content while maintaining a consistent
    /// appearance when not in use.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                if hasTitle {
                    Text(viewModel.title)
                        .font(.headline)
                }
                SecureField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value)
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
        .onChange(of: viewModel.validationResult) { _, newValue in
            withAnimation {
                hasError = newValue != .success
            }
        }

        if shouldDisplayClearButton {
            Button {
                viewModel.value = ""
            } label: {
                Image(systemName: "xmark.circle")
            }
            .buttonStyle(.borderless)
        }
    }

    /// Determines whether the clear button should be displayed.
    ///
    /// The visibility is controlled by:
    /// - The `clearValueMode` parameter
    /// - Whether the field is currently focused
    /// - The `isReadOnly` property of the view model
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

    /// Checks if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }
}

#Preview("Default") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "",
        title: "Password",
        placeholder: "P@$$w0rd",
        isReadOnly: false
    )

    Form {
        FormSecureTextField(viewModel)
    }
}

#Preview("With Validation") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "weak",
        title: "Password",
        placeholder: "Enter secure password",
        validation: .of(.minLength(8))
    )

    Form {
        FormSecureTextField(viewModel)
            .onAppear {
                _ = viewModel.validate()
            }
    }
}

#Preview("With Clear Button") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Secret123!",
        title: "Password",
        placeholder: "Enter password"
    )

    Form {
        FormSecureTextField(viewModel, clearValueMode: .always)
    }
}

#Preview("Leading Alignment") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Secret123!",
        title: "Password",
        placeholder: "Enter password"
    )

    Form {
        FormSecureTextField(viewModel, alignment: .leading)
    }
}
