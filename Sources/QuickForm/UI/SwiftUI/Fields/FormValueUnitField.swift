// FormValueUnitField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 20:51 GMT.

import Foundation
import SwiftUI

/// A SwiftUI view that represents a field for inputting a value with an associated unit of measurement.
///
/// `FormValueUnitField` is designed to work with ``FormFieldViewModel<Measurement<T>>`` to provide
/// an interface for inputting a numeric value along with a selectable unit of measurement.
/// This is particularly useful for fields where both a quantity and its unit need to be specified,
/// and in contrast to ``FormValueDimensionField``, units are not automatically converted when changed.
/// Use this component when you want to preserve the exact numeric value when changing units.
///
/// ## Features
/// - Displays a text field for the numeric value alongside a picker for the unit
/// - Supports any `Unit` type that conforms to ``AllValues``
/// - Maintains the same numeric value when changing units (no automatic conversion)
/// - Supports customizable picker styles for the unit selection
/// - Can be set to read-only mode
/// - Integrates with form validation
///
/// ## Examples
///
/// ### Basic Usage with UnitMass
///
/// ```swift
/// struct ProductForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: Measurement(value: 2.5, unit: UnitMass.kilograms),
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
///
/// ### Temperature Input with Custom Picker Style
///
/// ```swift
/// struct RecipeForm: View {
///     @State private var temperatureVM = FormFieldViewModel(
///         value: Measurement(value: 180, unit: UnitTemperature.celsius),
///         title: "Baking Temperature:",
///         placeholder: "Enter temperature"
///     )
///
///     var body: some View {
///         Form {
///             FormValueUnitField(
///                 temperatureVM,
///                 pickerStyle: .segmented
///             )
///         }
///     }
/// }
/// ```
///
/// ### Integration with QuickForm Models
///
/// ```swift
/// @QuickForm(Product.self)
/// class ProductFormModel: Validatable {
///     @PropertyEditor(keyPath: \Product.weight)
///     var weight = FormFieldViewModel(
///         value: Measurement(value: 0, unit: UnitMass.kilograms),
///         title: "Weight:",
///         validation: .of(.greaterThan(0, "Weight must be greater than 0"))
///     )
/// }
///
/// struct ProductEditView: View {
///     @Bindable var model: ProductFormModel
///
///     var body: some View {
///         Form {
///             FormValueUnitField(model.weight)
///                 .validationState(model.weight.validationResult)
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormValueDimensionField``, ``AllValues``
public struct FormValueUnitField<T: Unit, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>>
    @FocusState private var isFocused: Bool
    private let pickerStyle: S

    /// The body of the `FormValueUnitField` view.
    ///
    /// This view consists of:
    /// - A title label
    /// - A text field for entering the numeric value
    /// - A picker for selecting the unit of measurement
    ///
    /// Unlike ``FormValueDimensionField``, when the unit is changed, the numeric value
    /// remains the same - it does not automatically convert between units.
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

    /// Initializes a new `FormValueUnitField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this value-unit field.
    ///     The view model must have a value of type `Measurement<T>` where `T` is a
    ///     `Unit` type that conforms to ``AllValues``.
    ///   - pickerStyle: The style to apply to the unit picker. Defaults to `.menu`.
    ///     Common values include:
    ///     - `.menu`: A dropdown menu (default and space-efficient)
    ///     - `.segmented`: A segmented control (good for a small number of units)
    ///     - `.wheel`: A wheel picker (iOS, good for scrolling through many options)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic usage with menu picker
    /// FormValueUnitField(weightViewModel)
    ///
    /// // With segmented picker for temperature units
    /// FormValueUnitField(
    ///     temperatureViewModel,
    ///     pickerStyle: .segmented
    /// )
    /// ```
    public init(
        _ viewModel: FormFieldViewModel<Measurement<T>>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
        isFocused = false
    }
}

#Preview("Basic") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 34, unit: .kilograms),
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormValueUnitField(viewModel)
    }
}

#Preview("With Placeholder") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 0, unit: .kilograms),
        title: "Weight",
        placeholder: "Enter weight"
    )

    Form {
        FormValueUnitField(viewModel)
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 75, unit: .kilograms),
        title: "Weight",
        isReadOnly: true
    )

    Form {
        FormValueUnitField(viewModel)
    }
}

#Preview("Segmented Style") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitTemperature>(value: 180, unit: .celsius),
        title: "Temperature"
    )

    Form {
        FormValueUnitField(viewModel, pickerStyle: .segmented)
    }
}
