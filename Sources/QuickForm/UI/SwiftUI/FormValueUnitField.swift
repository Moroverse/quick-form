// FormValueUnitField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 20:51 GMT.

import Foundation
import SwiftUI

public protocol AllValues {
    associatedtype Unit: Identifiable
    static var allCases: [Unit] { get }
}

extension UnitMass: @retroactive Identifiable {}

extension UnitMass: AllValues {
    public static var allCases: [UnitMass] { [
        UnitMass.kilograms,
        UnitMass.grams,
        UnitMass.decigrams,
        UnitMass.centigrams,
        UnitMass.milligrams,
        UnitMass.micrograms,
        UnitMass.nanograms,
        UnitMass.picograms,
        UnitMass.ounces,
        UnitMass.pounds,
        UnitMass.stones,
        UnitMass.metricTons,
        UnitMass.shortTons,
        UnitMass.carats,
        UnitMass.ouncesTroy,
        UnitMass.slugs
    ] }
}

public struct FormValueUnitField<T: Dimension, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>>
    private let pickerStyle: S

    public var body: some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            TextField(String(localized: viewModel.placeholder ?? ""), value: $viewModel.value.value, format: .number)
                .multilineTextAlignment(.trailing)
                .disabled(viewModel.isReadOnly)
            let binding = Binding(get: {
                viewModel.value.unit
            }, set: { newUnit, _ in
                viewModel.value.convert(to: newUnit)
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

    public init(
        _ viewModel: FormFieldViewModel<Measurement<T>>,
        pickerStyle: S = DefaultPickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 34, unit: .kilograms),
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormValueUnitField(viewModel)
    }
}
