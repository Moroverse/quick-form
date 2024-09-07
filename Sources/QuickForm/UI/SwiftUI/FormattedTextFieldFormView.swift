// FormattedTextFieldFormView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import SwiftUI

public struct FormattedTextFieldFormView<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    @Bindable private var viewModel: FormattedPropertyViewModel<F>
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing

    public var body: some View {
        HStack {
            Text(viewModel.title)

            TextField(
                viewModel.title,
                value: $viewModel.value,
                format: viewModel.format
            )
            .focused($isFocused)
            .multilineTextAlignment(alignment)
        }
        .onChange(of: isFocused) {
            if isFocused {
                alignment = .leading
            } else {
                alignment = .trailing
            }
        }
    }

    public init(_ viewModel: FormattedPropertyViewModel<F>) {
        self.viewModel = viewModel
    }

    private var prompt: Text? {
        if let placeholder = viewModel.placeholder {
            Text(placeholder)
        } else {
            nil
        }
    }
}
