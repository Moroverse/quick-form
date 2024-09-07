// FormToggleField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

public struct FormToggleField: View {
    @Bindable private var viewModel: FormFieldViewModel<Bool>

    public var body: some View {
        Toggle(viewModel.title, isOn: $viewModel.value)
            .font(.headline)
            .disabled(viewModel.isReadOnly)
    }

    public init(_ viewModel: FormFieldViewModel<Bool>) {
        self.viewModel = viewModel
    }
}

struct FormToggleField_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var viewModel = FormFieldViewModel(
            value: false,
            title: "Established",
            isReadOnly: false
        )

        var body: some View {
            FormToggleField(viewModel)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
