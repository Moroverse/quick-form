// FormOptionalValueUnitField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-10-25 03:51 GMT.

import Foundation
import SwiftUI

public struct FormOptionalValueUnitField<T: Unit, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>?>
    @FocusState private var isFocused: Bool
    private let pickerStyle: S
    private let defaultValue: Measurement<T>

    public var body: some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            TextField(String(localized: viewModel.placeholder ?? ""), value: $viewModel.value.unwrapped(defaultValue: defaultValue).value, format: .number)
                .focused($isFocused)
                .multilineTextAlignment(.trailing)
                .disabled(viewModel.isReadOnly)
                .onSubmit {
                    isFocused = false
                }
            let binding = Binding(get: {
                viewModel.value?.unit ?? defaultValue.unit
            }, set: { newUnit, _ in
                viewModel.value = Measurement<T>(value: viewModel.value?.value ?? defaultValue.value, unit: newUnit)
            })
            Picker("", selection: binding) {
                let allCases = T.allCases
                ForEach(allCases) {
                    Text($0.symbol)
                        .tag($0)
                }
            }
            .pickerStyle(pickerStyle)
            .fixedSize()
            .disabled(viewModel.isReadOnly)
        }
    }

    /// Initializes a new `FormValueDimensionField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this value-unit field.
    ///   - pickerStyle: The style to apply to the unit picker. Defaults to `.menu`.
    public init(
        _ viewModel: FormFieldViewModel<Measurement<T>?>,
        defaultValue: Measurement<T>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.defaultValue = defaultValue
        self.pickerStyle = pickerStyle
        isFocused = false
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.none,
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormOptionalValueUnitField(viewModel, defaultValue: Measurement<UnitMass>(value: 34, unit: .kilograms))
    }
}
