// FormSecureTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-15 05:19 GMT.

import SwiftUI

public struct FormSecureTextField: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: TextAlignment
    let clearValueMode: ClearValueMode

    /// Initializes a new `FormOptionalTextField`.
    ///
    /// - Parameter viewModel: The view model that manages the state of this text field.
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
        .onChange(of: viewModel.errorMessage) { _, newValue in
            withAnimation {
                hasError = newValue != nil
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
