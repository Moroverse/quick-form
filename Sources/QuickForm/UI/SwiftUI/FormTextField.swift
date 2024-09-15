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

extension TextInputAutocapitalization {
    init(_ type: AutocapitalizationType) {
        switch type {
        case .words: self = .words
        case .sentences: self = .sentences
        case .never: self = .never
        case .characters: self = .characters
        }
    }
}

public struct FormTextField: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var resolvedAlignment: TextAlignment
    @State private var hasError: Bool
    let alignment: ValueAlignment
    let clearValueMode: ClearValueMode
    let autocapitalizationType: AutocapitalizationType

    public init(
        _ viewModel: FormFieldViewModel<String>,
        alignment: ValueAlignment = .trailing,
        clearValueMode: ClearValueMode = .never,
        autocapitalizationType: AutocapitalizationType = .never
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.alignment = alignment
        self.autocapitalizationType = autocapitalizationType
        hasError = viewModel.errorMessage != nil
        resolvedAlignment = alignment.textAlignment
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
                    .textInputAutocapitalization(TextInputAutocapitalization(autocapitalizationType))
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
                    resolvedAlignment = isFocused ? .leading : alignment.textAlignment
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
