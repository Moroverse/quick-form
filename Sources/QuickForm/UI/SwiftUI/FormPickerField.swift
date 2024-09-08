// FormPickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

public struct FormPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: PickerFieldViewModel<Property>
    private let pickerStyle: S

    public init(
        _ viewModel: PickerFieldViewModel<Property>,
        pickerStyle: S = DefaultPickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    public var body: some View {
        Picker(selection: $viewModel.value) {
            ForEach(viewModel.allValues, id: \.self) { itemCase in
                Text(itemCase.description)
            }
        } label: {
            Text(viewModel.title)
                .font(.headline)
        }
        .pickerStyle(pickerStyle)
        .disabled(viewModel.isReadOnly)
    }
}

public struct FormOptionalPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: OptionalPickerFieldViewModel<Property>
    private let pickerStyle: S

    public init(
        _ viewModel: OptionalPickerFieldViewModel<Property>,
        pickerStyle: S = DefaultPickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }

    public var body: some View {
        Picker(selection: $viewModel.value) {
            Text("None")
                .tag(Optional<Property>.none)
            ForEach(viewModel.allValues, id: \.self) { itemCase in
                Text(itemCase.description)
            }
        } label: {
            Text(viewModel.title)
                .font(.headline)
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
