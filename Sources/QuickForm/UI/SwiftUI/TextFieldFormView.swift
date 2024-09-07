// TextFieldFormView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import SwiftUI

public struct TextFieldFormView: View {
    @Bindable private var viewModel: PropertyViewModel<String>
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing

    public var body: some View {
        HStack {
            Text(viewModel.title)

            TextField(
                viewModel.title,
                text: $viewModel.value,
                prompt: prompt
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

    public init(_ viewModel: PropertyViewModel<String>) {
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
