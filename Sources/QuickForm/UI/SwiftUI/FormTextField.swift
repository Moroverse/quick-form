// FormTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

public struct FormTextField: View {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @Bindable private var viewModel: FormFieldViewModel<String>

    public init(_ viewModel: FormFieldViewModel<String>) {
        self.viewModel = viewModel
        isFocused = false
    }

    public var body: some View {
        HStack(spacing: 10) {
            Text(viewModel.title)
                .font(.headline)
            TextField(viewModel.placeholder ?? "", text: $viewModel.value)
                .focused($isFocused)
                .multilineTextAlignment(alignment)
                .disabled(viewModel.isReadOnly)
        }.onChange(of: isFocused) {
            alignment = isFocused ? .leading : .trailing
        }
    }
}

#Preview {
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
