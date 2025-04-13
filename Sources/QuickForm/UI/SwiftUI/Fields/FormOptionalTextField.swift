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
/// This view is typically used in conjunction with a ``FormFieldViewModel<String?>`` to manage its state
/// and integrates seamlessly with other form components from the QuickForm framework.
///
/// ## Features
/// - Handles optional string values (`String?`)
/// - Displays a title for the field
/// - Supports placeholder text when empty
/// - Shows validation error messages
/// - Adapts its text alignment based on focus state
/// - Supports read-only mode
/// - Provides configurable clear button functionality
/// - Platform-specific features like autocapitalization on iOS
///
/// ## Examples
///
/// ### Basic Usage
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
///
/// ### With Validation
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \Person.email)
///     var email = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Email Address:",
///         placeholder: "Enter email (optional)",
///         validation: .of(.emailOptional)
///     )
///
///     @PropertyEditor(keyPath: \Person.phoneNumber)
///     var phone = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Phone:",
///         placeholder: "(555) 555-5555",
///         validation: .of(.phoneNumberOptional)
///     )
/// }
///
/// struct ProfileFormView: View {
///     @Bindable var model: PersonFormModel
///
///     var body: some View {
///         Form {
///             FormOptionalTextField(model.email)
///                 .validationState(model.email.validationResult)
///                 .keyboardType(.emailAddress)
///
///             FormOptionalTextField(model.phone)
///                 .validationState(model.phone.validationResult)
///                 .keyboardType(.phonePad)
///         }
///     }
/// }
/// ```
///
/// ### With Custom Styling
///
/// ```swift
/// // Leading alignment with clear button while editing
/// FormOptionalTextField(
///     viewModel,
///     alignment: .leading,
///     clearValueMode: .whileEditing
/// )
///
/// // With autocapitalization for names (iOS only)
/// FormOptionalTextField(
///     nameViewModel,
///     alignment: .leading,
///     clearValueMode: .always,
///     autocapitalizationType: .words
/// )
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormTextField``, ``ClearValueMode``, ``ValidationResult``
public struct FormOptionalTextField: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String?>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode
    #if os(iOS)
        let autocapitalizationType: TextInputAutocapitalization
    #endif

    /// Initializes a new `FormOptionalTextField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this text field.
    ///   - alignment: The text alignment to use when the field is not focused. Defaults to `.trailing`.
    ///     When the field gains focus, alignment temporarily changes to `.leading` for easier editing.
    ///   - clearValueMode: Controls when the clear button appears. Defaults to `.never`.
    ///     - `.never`: Never show a clear button
    ///     - `.always`: Always show a clear button when the field has content
    ///     - `.whileEditing`: Show a clear button only when the field is focused
    ///     - `.unlessEditing`: Show a clear button except when the field is focused
    ///   - autocapitalizationType: The autocapitalization style to use for the text field (iOS only).
    ///     Defaults to `.never`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic usage with default settings
    /// FormOptionalTextField(viewModel)
    ///
    /// // With custom alignment and clear button
    /// FormOptionalTextField(
    ///     notesViewModel,
    ///     alignment: .leading,
    ///     clearValueMode: .whileEditing
    /// )
    ///
    /// // iOS-specific with word capitalization
    /// FormOptionalTextField(
    ///     nameViewModel,
    ///     alignment: .leading,
    ///     clearValueMode: .always,
    ///     autocapitalizationType: .words
    /// )
    /// ```
    #if os(iOS)
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
    #else
        public init(
            _ viewModel: FormFieldViewModel<String?>,
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
    #endif

    /// The body of the `FormOptionalTextField` view.
    ///
    /// This view consists of:
    /// - A title label if a title is provided in the view model
    /// - An optional text field that shows a placeholder when empty
    /// - A clear button (when enabled by `clearValueMode`)
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
                TextField(
                    String(
                        localized: viewModel.placeholder ?? ""
                    ),
                    text: $viewModel.value.unwrapped(defaultValue: "")
                )
                #if os(iOS)
                .textInputAutocapitalization(autocapitalizationType)
                #endif
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
                viewModel.value = nil
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

#Preview("Basic") {
    @Previewable @State var viewModel = FormFieldViewModel<String?>(
        value: nil,
        title: "Middle Name:",
        placeholder: "Enter middle name (optional)"
    )

    Form {
        FormOptionalTextField(viewModel)
    }
}

#Preview("With Value") {
    @Previewable @State var viewModel = FormFieldViewModel<String?>(
        value: "John",
        title: "Middle Name:",
        placeholder: "Enter middle name (optional)"
    )

    Form {
        FormOptionalTextField(viewModel)
    }
}

#Preview("With Validation") {
    @Previewable @State var viewModel = FormFieldViewModel<String?>(
        type: String?.self,
        title: "Email:",
        placeholder: "Enter email address (optional)",
        validation: .of(.required())
    )

    Form {
        FormOptionalTextField(viewModel)
            .onAppear {
                _ = viewModel.validate()
            }
    }
}

#Preview("With Clear Button") {
    @Previewable @State var viewModel = FormFieldViewModel<String?>(
        value: "Some text",
        title: "Notes:",
        placeholder: "Enter notes (optional)"
    )

    Form {
        FormOptionalTextField(viewModel, clearValueMode: .always)
    }
}

#Preview("Alignment") {
    @Previewable @State var viewModel1 = FormFieldViewModel<String?>(
        value: "Trailing text",
        title: "Trailing (default):",
        placeholder: "Enter text"
    )

    @Previewable @State var viewModel2 = FormFieldViewModel<String?>(
        value: "Leading text",
        title: "Leading:",
        placeholder: "Enter text"
    )

    Form {
        FormOptionalTextField(viewModel1)
        FormOptionalTextField(viewModel2, alignment: .leading)
    }
}
