// DatePickerFormView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import SwiftUI

public struct DatePickerView<S: DatePickerStyle>: View {
    @Bindable private var viewModel: PropertyViewModel<Date>
    private let displayedComponents: DatePickerComponents
    private var style: S

    init(
        viewModel: PropertyViewModel<Date>,
        displayedComponents: DatePickerComponents = [.date],
        style: S
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

struct DatePickerView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var viewModel = PropertyViewModel(
            value: Date(),
            title: "Birthday",
            isReadOnly: false
        )

        var body: some View {
            DatePickerView(viewModel: viewModel, style: .compact)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
