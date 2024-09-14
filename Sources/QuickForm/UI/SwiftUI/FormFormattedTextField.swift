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
    @State private var resolvedAlignment: TextAlignment
    @State private var editingText = ""
    @State private var originalValue: F.FormatInput?
    @Bindable private var viewModel: FormattedFieldViewModel<F>

    public init(_ viewModel: FormattedFieldViewModel<F>) {
        self.viewModel = viewModel
        resolvedAlignment = viewModel.alignment.textAlignment
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
            if hasTitle {
                Text(viewModel.title)
                    .font(.headline)
            }
            TextField(
                String(localized: viewModel.placeholder ?? ""),
                text: $editingText
            )
            .focused($isFocused)
            .multilineTextAlignment(resolvedAlignment)
            .disabled(viewModel.isReadOnly)
            .onAppear {
                editingText = viewModel.format.format(viewModel.value)
            }
            .onChange(of: isFocused) { _, newValue in
                withAnimation {
                    if newValue {
                        // Entering edit mode: enforce leading
                        resolvedAlignment = .leading
                        // Entering edit mode: remove formatting
                        editingText = safeExtract()
                        originalValue = viewModel.value
                    } else {
                        // Entering edit mode: restore alignment
                        resolvedAlignment = viewModel.alignment.textAlignment
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
            .onChange(of: viewModel.alignment) {
                if !isFocused {
                    withAnimation {
                        resolvedAlignment = viewModel.alignment.textAlignment
                    }
                }
            }
            if shouldDisplayClearButton {
                Button {
                    editingText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.borderless)
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
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: "Amount:"
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}

#Preview("No Title") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: ""
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}

#Preview("Alignment") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: "",
        alignment: .leading
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}

#Preview("Placeholder") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: Double?.none,
        format: OptionalFormat(format: .currency(code: "USD")),
        title: "",
        placeholder: "234000",
        alignment: .leading
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}

#Preview("Clear Value") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: "Amount:",
        clearValueMode: .whileEditing
    )

    Form {
        FormFormattedTextField(viewModel)
    }
}
