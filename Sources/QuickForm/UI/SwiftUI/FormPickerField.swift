// FormPickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

struct FormPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: PickerFieldViewModel<Property>
    private let pickerStyle: S

    init(
        _ viewModel: PickerFieldViewModel<Property>,
        pickerStyle: S = DefaultPickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    var body: some View {
        Picker(viewModel.title, selection: $viewModel.value) {
            ForEach(viewModel.allValues, id: \.self) { itemCase in
                Text(itemCase.description)
            }
        }
        .pickerStyle(pickerStyle)
        .disabled(viewModel.isReadOnly)
    }
}

#Preview {
    @Previewable @State var viewModel = PickerFieldViewModel(value: 1, allValues: [0, 1, 2, 3])
    Form {
        FormPickerField(viewModel)
    }
}
