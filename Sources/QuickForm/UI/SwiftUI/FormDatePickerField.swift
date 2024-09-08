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
        DatePicker(String(localized: viewModel.title), selection: $viewModel.value, displayedComponents: displayedComponents)
            .font(.headline)
            .datePickerStyle(style)
            .disabled(viewModel.isReadOnly)
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Date(),
        title: "Birthday",
        isReadOnly: false
    )

    Form {
        FormDatePickerField(viewModel)
    }
}
