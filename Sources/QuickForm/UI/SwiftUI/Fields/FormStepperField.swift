// FormStepperField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 18:56 GMT.

import SwiftUI

public struct FormStepperField<Value: Strideable>: View {
    @Bindable private var viewModel: FormFieldViewModel<Value>
    private let range: ClosedRange<Value>?
    private let step: Value.Stride
    public  var body: some View {
        if let range {
            Stepper(
                value: $viewModel.value,
                in: range,
                step: step,
                label: label
            )
        } else {
            Stepper(
                value: $viewModel.value,
                step: step,
                label: label
            )
        }
    }

    public init(viewModel: FormFieldViewModel<Value>, range: ClosedRange<Value>? = nil, step: Value.Stride) {
        self.viewModel = viewModel
        self.range = range
        self.step = step
    }

    private func label() -> some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            Text("\(viewModel.value)")
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Int(0),
        title: "Count:"
    )

    Form {
        FormStepperField(viewModel: viewModel, step: 1)
    }
}
