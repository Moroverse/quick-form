// FormTextField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

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
        .onChange(of: viewModel.errorMessage) { _, newValue in
            withAnimation {
                hasError = newValue != nil
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

#Preview("Not Title") {
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
