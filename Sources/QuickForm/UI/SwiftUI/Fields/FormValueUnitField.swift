// FormValueUnitField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 20:51 GMT.

import Foundation
import SwiftUI

/// A SwiftUI view that represents a field for inputting a value with an associated unit of measurement.
///
/// `FormValueUnitField` is designed to work with `FormFieldViewModel<Measurement<T>>` to provide
/// an interface for inputting a numeric value along with a selectable unit of measurement.
/// This is particularly useful for fields where both a quantity and its unit need to be specified,
/// and in contrast to dimension field, units are not convertible.
///
/// ## Features
/// - Displays a text field for the numeric value alongside a picker for the unit
/// - Supports any `Unit` type that conforms to `AllValues`
/// - Supports customizable picker styles for the unit selection
/// - Can be set to read-only mode
///
/// ## Example
///
/// ```swift
/// struct ProductForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: Measurement(value: 1.5, unit: UnitMass.kilograms),
///         title: "Weight:"
///     )
///
///     var body: some View {
///         Form {
///             FormValueUnitField(viewModel)
///         }
///     }
/// }
/// ```
public struct FormValueUnitField<T: Unit, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>>
    @FocusState private var isFocused: Bool
    private let pickerStyle: S

    public var body: some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            TextField(String(localized: viewModel.placeholder ?? ""), value: $viewModel.value.value, format: .number)
                .focused($isFocused)
                .multilineTextAlignment(.trailing)
                .disabled(viewModel.isReadOnly)
                .onSubmit {
                    isFocused = false
                }
            let binding = Binding(get: {
                viewModel.value.unit
            }, set: { newUnit, _ in
                viewModel.value = .init(value: viewModel.value.value, unit: newUnit)
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
        _ viewModel: FormFieldViewModel<Measurement<T>>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
        isFocused = false
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
