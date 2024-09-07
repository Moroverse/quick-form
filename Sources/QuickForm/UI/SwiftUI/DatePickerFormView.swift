// DatePickerFormView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 17:15 GMT.

import SwiftUI

public struct DatePickerFormView: View {
    @Bindable private var viewModel: PropertyViewModel<Date>
    public var body: some View {
        DatePicker(viewModel.title, selection: $viewModel.value)
    }

    public init(_ viewModel: PropertyViewModel<Date>) {
        self.viewModel = viewModel
    }
}

public extension DatePickerFormView {
    func title(_ title: String) -> Self {
        viewModel.title = title
        return self
    }
}
