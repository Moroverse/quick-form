// FormTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a text field in a form.
///
/// `FormTextField` is designed to work with ``FormFieldViewModel<String>`` to provide
/// a customizable text input field for forms. The component supports dynamic alignment
/// changes on focus, clear button functionality, validation feedback, and accessibility features.
///
/// ## Features
/// - Displays a single-line text field with an optional title
/// - Supports customizable text alignment
/// - Dynamically adjusts alignment based on focus state for better usability
/// - Shows validation error messages when validation fails
/// - Provides configurable clear button functionality
/// - Supports iOS-specific text input customization like autocapitalization
/// - Includes accessibility identifiers for UI testing
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct NameForm: View {
///     @State private var nameModel = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     var body: some View {
///         Form {
///             FormTextField(nameModel)
///         }
///     }
/// }
/// ```
///
/// ### With Custom Alignment and Clear Button
///
/// ```swift
/// FormTextField(
///     emailViewModel,
///     alignment: .leading,
///     clearValueMode: .whileEditing
/// )
/// ```
///
/// ### Integrated with Form Validation
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name:",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
/// }
///
/// struct PersonEditView: View {
///     @Bindable var model: PersonEditModel
///
///     var body: some View {
///         Form {
///             FormTextField(model.firstName, autocapitalizationType: .words)
///             FormTextField(model.lastName, autocapitalizationType: .words)
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormOptionalTextField``, ``FormSecureTextField``, ``ClearValueMode``
public struct FormTextField: View {
    #if DEBUG
        let inspection = Inspection<Self>()
    #endif
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode
    #if os(iOS)
        let autocapitalizationType: TextInputAutocapitalization
    #endif

    /// Initializes a new `FormTextField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this text field.
    ///   - alignment: The text alignment to use when the field is not focused. Defaults to `.trailing`.
    ///     When the field gains focus, alignment temporarily changes to `.leading` for easier editing.
    ///   - clearValueMode: Controls when the clear button appears. Defaults to `.never`.
    ///     - `.never`: Never show a clear button
    ///     - `.always`: Always show a clear button
    ///     - `.whileEditing`: Show a clear button only when the field is focused
    ///     - `.unlessEditing`: Show a clear button except when the field is focused
    ///   - autocapitalizationType: The autocapitalization style to use for the text field (iOS only).
    ///     Defaults to `.never`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic text field with default settings
    /// FormTextField(nameViewModel)
    ///
    /// // Text field with custom alignment and clear button behavior
    /// FormTextField(
    ///     emailViewModel,
    ///     alignment: .leading,
    ///     clearValueMode: .whileEditing
    /// )
    ///
    /// // iOS-specific with word capitalization
    /// FormTextField(
    ///     nameViewModel,
    ///     alignment: .leading,
    ///     clearValueMode: .always,
    ///     autocapitalizationType: .words
    /// )
    /// ```
    #if os(iOS)
        public init(
            _ viewModel: FormFieldViewModel<String>,
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
    #endif

    /// The body of the `FormTextField` view.
    ///
    /// This view consists of:
    /// - A title label (when provided)
    /// - A text field that adjusts its alignment based on focus state
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
                        .accessibilityIdentifier("TITLE")
                        .font(.headline)
                }
                TextField(String(localized: viewModel.placeholder ?? ""), text: $viewModel.value)
                    .accessibilityIdentifier("VALUE")
                    .focused($isFocused)
                    .multilineTextAlignment(resolvedAlignment)
                    .disabled(viewModel.isReadOnly)
                #if os(iOS)
                    .textInputAutocapitalization(autocapitalizationType)
                #endif
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
        .registerForInspection(inspection, in: self)

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

#if DEBUG
    extension FormTextField: InspectableForm {}
#endif

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
        isReadOnly: false
    )

    Form {
        FormTextField(viewModel)
    }
}

#Preview("No Title") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextField(viewModel)
    }
}

#Preview("With Clear Button") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "Name",
        placeholder: "Enter name",
        isReadOnly: false
    )

    Form {
        FormTextField(viewModel, clearValueMode: .always)
    }
}

#Preview("With Validation Error") {
    @Previewable @State var viewModel = FormFieldViewModel(
        type: String.self,
        title: "Email",
        placeholder: "Enter email",
        validation: .of(.email)
    )

    Form {
        FormTextField(viewModel)
            .onAppear {
                _ = viewModel.validate()
            }
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "user@example.com",
        title: "Email",
        placeholder: "Enter email",
        isReadOnly: true
    )

    Form {
        FormTextField(viewModel)
    }
}
