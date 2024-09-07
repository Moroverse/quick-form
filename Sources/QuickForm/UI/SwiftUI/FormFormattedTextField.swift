// FormFormattedTextField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

public struct FormFormattedTextField<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @Bindable private var viewModel: FormattedFieldViewModel<F>

    public init(_ viewModel: FormattedFieldViewModel<F>) {
        self.viewModel = viewModel
        isFocused = false
    }

    public var body: some View {
        HStack(spacing: 10) {
            Text(viewModel.title)
                .font(.headline)
            TextField(
                viewModel.placeholder ?? "",
                value: $viewModel.value,
                format: viewModel.format
            )
            .focused($isFocused)
            .multilineTextAlignment(alignment)
            .disabled(viewModel.isReadOnly)
        }.onChange(of: isFocused) {
            alignment = isFocused ? .leading : .trailing
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
