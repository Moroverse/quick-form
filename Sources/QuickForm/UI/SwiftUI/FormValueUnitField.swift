// FormValueUnitField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 20:51 GMT.

import Foundation
import SwiftUI

/// A protocol that defines a type with all possible cases.
///
/// This protocol is used to constrain the unit type in `FormValueUnitField` to ensure
/// that all possible units can be displayed in the picker.
public protocol AllValues {
    associatedtype Unit: Identifiable
    static var allCases: [Unit] { get }
}

/// A SwiftUI view that represents a field for inputting a value with an associated unit of measurement.
///
/// `FormValueUnitField` is designed to work with `FormFieldViewModel<Measurement<T>>` to provide
/// an interface for inputting a numeric value along with a selectable unit of measurement.
/// This is particularly useful for fields where both a quantity and its unit need to be specified,
/// such as weight, length, or any other measurable quantity.
///
/// ## Features
/// - Displays a text field for the numeric value alongside a picker for the unit
/// - Supports any `Dimension` type that conforms to `AllValues`
/// - Automatically converts the value when the unit is changed
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
public struct FormValueUnitField<T: Dimension, S: PickerStyle>: View where T: AllValues, T.Unit == T {
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

    /// Initializes a new `FormValueUnitField`.
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
        self.isFocused = false
    }
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
