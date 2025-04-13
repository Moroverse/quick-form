// FormFormattedTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a formatted text field in a form.
///
/// `FormFormattedTextField` is designed to work with ``FormattedFieldViewModel`` to provide
/// a text field that automatically formats its input and output according to a specified
/// format style. This is particularly useful for fields like currency, numbers, percentages,
/// or any other data that needs to be displayed in a specific format while storing a different underlying value.
///
/// When the field gains focus, it switches to an unformatted representation for easier editing.
/// When it loses focus, the input is parsed and formatted according to the specified format style.
///
/// ## Features
/// - Displays a formatted text field with a title
/// - Supports various format styles through ``ParseableFormatStyle``
/// - Handles focus state to adjust text alignment and formatting
/// - Supports placeholder text for empty fields
/// - Provides automatic input masking for common formats (phone numbers, credit cards, etc.)
/// - Can be set to read-only mode
/// - Preserves the underlying value type while displaying formatted text
/// - Shows validation errors when validation fails
///
/// ## Examples
///
/// ### Basic Currency Field
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
///
/// ### Number Field with Custom Alignment
///
/// ```swift
/// FormFormattedTextField(
///     viewModel,
///     alignment: .leading,
///     clearValueMode: .whileEditing
/// )
/// ```
///
/// ### Phone Number with Auto-Masking
///
/// ```swift
/// let phoneViewModel = FormattedFieldViewModel(
///     value: "",
///     format: PlainStringFormat(),
///     title: "Phone Number:",
///     placeholder: "(555) 555-5555",
///     validation: .of(.usPhoneNumber)
/// )
///
/// FormFormattedTextField(phoneViewModel, autoMask: .phone)
///     .keyboardType(.phonePad)
/// ```
///
/// ### Credit Card Field
///
/// ```swift
/// let cardViewModel = FormattedFieldViewModel(
///     value: "",
///     format: PlainStringFormat(),
///     title: "Credit Card:",
///     placeholder: "1234 5678 9012 3456"
/// )
///
/// FormFormattedTextField(cardViewModel, autoMask: .creditCard)
///     .keyboardType(.numberPad)
///     .trailingAccessories {
///         Image(systemName: "creditcard")
///             .foregroundColor(.secondary)
///     }
/// ```
///
/// ### Percentage with Validation
///
/// ```swift
/// let percentViewModel = FormattedFieldViewModel(
///     value: 0.25,
///     format: .percent.precision(.fractionLength(2)),
///     title: "Discount:",
///     validation: .of(.range(0...1, "Discount must be between 0% and 100%"))
/// )
///
/// FormFormattedTextField(percentViewModel)
/// ```
///
/// - SeeAlso: ``FormattedFieldViewModel``, ``AutoMask``, ``ClearValueMode``, ``ParseableFormatStyle``
public struct FormFormattedTextField<F, V>: View where F: ParseableFormatStyle, F.FormatOutput == String, F.FormatInput: Equatable, V: View {
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode
    let autoMask: AutoMask?

    @FocusState private var isFocused: Bool
    @State private var resolvedAlignment: TextAlignment
    @State private var editingText = ""
    @State private var originalValue: F.FormatInput?
    @Bindable private var viewModel: FormattedFieldViewModel<F>
    @State private var hasError: Bool
    @State private var isAutoMasking = false

    private var trailingAccessoriesContent: (() -> V)?

    /// Creates a new formatted text field with the specified view model and options.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormattedFieldViewModel`` that manages the state of this field.
    ///   - alignment: The text alignment to use when the field is not focused. Defaults to `.trailing`.
    ///   - clearValueMode: Determines when the clear button should be visible. Defaults to `.never`.
    ///   - autoMask: An optional mask to apply to the input text as the user types.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormFormattedTextField(
    ///     salaryViewModel,
    ///     alignment: .trailing,
    ///     clearValueMode: .whileEditing,
    ///     autoMask: nil
    /// )
    /// ```
    public init(
        _ viewModel: FormattedFieldViewModel<F>,
        alignment: TextAlignment = .trailing,
        clearValueMode: ClearValueMode = .never,
        autoMask: AutoMask? = nil
    ) where V == Never {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        self.autoMask = autoMask
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
        isFocused = false
    }

    /// Creates a new formatted text field with the specified view model, options, and trailing accessories.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormattedFieldViewModel`` that manages the state of this field.
    ///   - alignment: The text alignment to use when the field is not focused.
    ///   - clearValueMode: Determines when the clear button should be visible.
    ///   - autoMask: An optional mask to apply to the input text as the user types.
    ///   - trailingAccessories: A view builder that returns content to display at the trailing edge of the field.
    ///
    /// This initializer is not typically called directly but through the `trailingAccessories(_:)` method.
    init(
        _ viewModel: FormattedFieldViewModel<F>,
        alignment: TextAlignment,
        clearValueMode: ClearValueMode,
        autoMask: AutoMask? = nil,
        @ViewBuilder trailingAccessories: @escaping () -> V
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        self.autoMask = autoMask
        trailingAccessoriesContent = trailingAccessories
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment
        isFocused = false
    }

    /// The body of the formatted text field.
    ///
    /// This view consists of:
    /// - An optional title
    /// - A text field that displays the formatted value when unfocused and the raw value when focused
    /// - An optional clear button based on the clearValueMode
    /// - Optional trailing accessories
    /// - An error message when validation fails
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
                .onChange(of: viewModel.value) { _, newValue in
                    if !isFocused {
                        editingText = viewModel.format.format(newValue)
                    }
                }
                .onChange(of: editingText) { _, newValue in
                    if let autoMask, isFocused {
                        // Only apply auto-masking when user is typing (not when programmatically changing text)
                        if !isAutoMasking {
                            isAutoMasking = true

                            // Filter out characters that aren't allowed by the mask
                            let filteredText = newValue.filter { autoMask.isAllowed(character: $0) }

                            // Apply the mask formatting
                            let maskedText = autoMask.apply(to: filteredText)

                            // Only update if the text would actually change
                            if maskedText != editingText {
                                editingText = maskedText
                            }

                            isAutoMasking = false
                        }
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
                .onChange(of: viewModel.validationResult) { _, newValue in
                    withAnimation {
                        hasError = newValue != .success
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

    /// Adds trailing accessories to the text field.
    ///
    /// This method returns a new `FormFormattedTextField` with the specified trailing accessories.
    ///
    /// - Parameter content: A view builder that returns the trailing accessories.
    /// - Returns: A new `FormFormattedTextField` with the specified trailing accessories.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormFormattedTextField(viewModel)
    ///     .trailingAccessories {
    ///         Button {
    ///             // Show info about this field
    ///         } label: {
    ///             Image(systemName: "info.circle")
    ///                 .foregroundColor(.blue)
    ///         }
    ///     }
    /// ```
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

#Preview("Phone Mask") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: "",
        format: PlainStringFormat(),
        title: "Phone Number:",
        placeholder: "(555) 555-5555"
    )

    Form {
        FormFormattedTextField(viewModel, autoMask: .phone)
    }
}

#Preview("Credit Card Mask") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: "",
        format: PlainStringFormat(),
        title: "Card Number:",
        placeholder: "1234 5678 9012 3456"
    )

    Form {
        FormFormattedTextField(viewModel, autoMask: .creditCard)
    }
}

#Preview("Pattern Mask") {
    @Previewable @State var viewModel = FormattedFieldViewModel(
        value: "",
        format: PlainStringFormat(),
        title: "Patient Record Number",
        placeholder: "MRN-XX-####"
    )

    Form {
        FormFormattedTextField(viewModel, autoMask: .pattern("MRN-XX-####", allowedCharacters: .alphanumerics))
    }
}
