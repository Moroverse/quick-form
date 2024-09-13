// FormFormattedTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a formatted text field in a form.
///
/// `FormFormattedTextField` is designed to work with `FormattedFieldViewModel` to provide
/// a text field that automatically formats its input and output according to a specified
/// format style. This is particularly useful for fields like currency, dates, or any other
/// data that needs to be displayed in a specific format while storing a different underlying value.
///
/// ## Features
/// - Displays a formatted text field with a title
/// - Supports custom format styles
/// - Handles focus state to adjust text alignment
/// - Supports placeholder text
/// - Can be set to read-only mode
/// - Preserves the underlying value type while displaying formatted text
///
/// ## Example
///
/// ```swift
/// struct EmployeeForm: View {
///     @State private var viewModel = FormattedFieldViewModel(
///         value: 50000.0,
///         format: .currency(code: "USD"),
///         title: "Salary:",
///         placeholder: "Enter annual salary"
///     )
///
///     var body: some View {
///         Form {
///             FormFormattedTextField(viewModel)
///         }
///     }
/// }
/// ```
public struct FormFormattedTextField<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @State private var editingText = ""
    @State private var originalValue: F.FormatInput?
    @Bindable private var viewModel: FormattedFieldViewModel<F>

    public init(_ viewModel: FormattedFieldViewModel<F>) {
        self.viewModel = viewModel
        isFocused = false
    }

    func safeExtract() -> String {
        if _isOptional(type(of: viewModel.value)) {
            var optional = String(describing: viewModel.value)
            if optional == "nil" {
                return ""
            }
            optional.trimPrefix("Optional(\"")
            let result = optional.split(separator: "\"")
            return String(result[0])
        } else {
            return String(describing: viewModel.value)
        }
    }

    public var body: some View {
        HStack(spacing: 10) {
            Text(viewModel.title)
                .font(.headline)
            TextField(
                String(localized: viewModel.placeholder ?? ""),
                text: $editingText
            )
            .focused($isFocused)
            .multilineTextAlignment(alignment)
            .disabled(viewModel.isReadOnly)
            .onAppear {
                editingText = viewModel.format.format(viewModel.value)
            }
            .onChange(of: isFocused) { _, newValue in
                withAnimation {
                    alignment = newValue ? .leading : .trailing
                    if newValue {
                        // Entering edit mode: remove formatting
                        editingText = safeExtract()
                        originalValue = viewModel.value
                    } else {
                        // Exiting edit mode: apply formatting
                        if let parsedValue = try? viewModel.format.parseStrategy.parse(editingText) {
                            viewModel.value = parsedValue
                            editingText = viewModel.format.format(viewModel.value)
                        } else if let originalValue {
                            viewModel.value = originalValue
                            editingText = viewModel.format.format(viewModel.value)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: "Amount:"
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}
