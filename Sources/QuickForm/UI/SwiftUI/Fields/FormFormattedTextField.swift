// FormFormattedTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a formatted text field in a form.
///
/// `FormFormattedTextField` is designed to work with `FormattedFieldViewModel` to provide
/// a text field that automatically formats its input and output according to a specified
/// format style. This is particularly useful for fields like currency, numbers, or any other
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
public struct FormFormattedTextField<F, V>: View where F: ParseableFormatStyle, F.FormatOutput == String, F.FormatInput: Equatable, V: View {
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode

    @FocusState private var isFocused: Bool
    @State private var resolvedAlignment: TextAlignment
    @State private var editingText = ""
    @State private var originalValue: F.FormatInput?
    @Bindable private var viewModel: FormattedFieldViewModel<F>
    @State private var hasError: Bool

    private var trailingAccessoriesContent: (() -> V)?

    public init(
        _ viewModel: FormattedFieldViewModel<F>,
        alignment: TextAlignment = .trailing,
        clearValueMode: ClearValueMode = .never
    ) where V == Never {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
        isFocused = false
    }

    init(
        _ viewModel: FormattedFieldViewModel<F>,
        alignment: TextAlignment,
        clearValueMode: ClearValueMode,
        @ViewBuilder trailingAccessories: @escaping () -> V
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        trailingAccessoriesContent = trailingAccessories
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
        isFocused = false
    }

    public var body: some View {
        VStack {
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
                .onSubmit {
                    isFocused = false
                }
                .onAppear {
                    editingText = viewModel.format.format(viewModel.value)
                }
                .onChange(of: viewModel.format) { _, _ in
                    editingText = viewModel.format.format(viewModel.value)
                }
                .onChange(of: viewModel.value) { newValue in
                    if !isFocused {
                        editingText = viewModel.format.format(newValue)
                    }
                }
                .onChange(of: isFocused) { _, newValue in
                    withAnimation {
                        if newValue {
                            // Entering edit mode: enforce leading
                            resolvedAlignment = .leading
                            // Entering edit mode: remove formatting
                            editingText = viewModel.rawStringValue
                            originalValue = viewModel.value
                        } else {
                            // Exiting edit mode: restore alignment
                            resolvedAlignment = alignment
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
                .onChange(of: viewModel.errorMessage) { _, newValue in
                    withAnimation {
                        hasError = newValue != nil
                    }
                }

                if shouldDisplayClearButton {
                    Button {
                        editingText = ""
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.borderless)
                }

                if let trailingAccessoriesContent {
                    trailingAccessoriesContent()
                }
            }
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
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

    public func trailingAccessories<Content: View>(_ content: @escaping () -> Content) -> FormFormattedTextField<F, Content> {
        .init(
            viewModel,
            alignment: alignment,
            clearValueMode: clearValueMode,
            trailingAccessories: content
        )
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
        title: ""
    )

    Form {
        FormFormattedTextField(viewModel, alignment: .leading)
    }
}

#Preview("Placeholder") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: Double?.none,
        format: OptionalFormat(format: .currency(code: "USD")),
        title: "",
        placeholder: "234000"
    )

    Form {
        FormFormattedTextField(viewModel, alignment: .leading)
    }
}

#Preview("Clear Value") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: 123,
        format: .currency(code: "USD"),
        title: "Amount:"
    )

    Form {
        FormFormattedTextField(viewModel, clearValueMode: .whileEditing)
    }
}
