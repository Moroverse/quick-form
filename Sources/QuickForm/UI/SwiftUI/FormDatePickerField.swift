// FormDatePickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

public struct FormDatePickerField<S: DatePickerStyle>: View {
    @Bindable private var viewModel: FormFieldViewModel<Date>
    private let displayedComponents: DatePickerComponents
    private var style: S

    public init(
        _ viewModel: FormFieldViewModel<Date>,
        displayedComponents: DatePickerComponents = [.date],
        style: S = DefaultDatePickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.displayedComponents = displayedComponents
        self.style = style
    }

    public var body: some View {
        DatePicker(viewModel.title, selection: $viewModel.value, displayedComponents: displayedComponents)
            .font(.headline)
            .datePickerStyle(style)
            .disabled(viewModel.isReadOnly)
    }
}

struct FormDatePickerField_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var viewModel = FormFieldViewModel(
            value: Date(),
            title: "Birthday",
            isReadOnly: false
        )

        var body: some View {
            FormDatePickerField(viewModel, style: .compact)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
