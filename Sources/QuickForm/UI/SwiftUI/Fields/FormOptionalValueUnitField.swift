// FormOptionalValueUnitField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-10-25 03:51 GMT.

import Foundation
import SwiftUI

/// A SwiftUI form field for editing optional measurement values with unit selection.
///
/// `FormOptionalValueUnitField` provides a field for editing measurements that include both
/// a numeric value and a unit of measure. This field is particularly useful for forms where
/// users need to input measurements like weight, distance, or temperature.
///
/// The field consists of:
/// - A text field for entering the numeric value
/// - A picker for selecting the unit of measure
/// - An optional label displaying the field title
///
/// The component handles optionality by using a default value when the value is `nil`.
///
/// ## Requirements
///
/// The generic type `T` must conform to both `Unit` and `AllValues` protocols, and the
/// `T.Unit` associated type must be identical to `T` itself. This ensures that the units
/// available for selection are of the same type as the unit in the measurement.
///
/// ## Examples
///
/// ### Basic Weight Field with Kilograms
///
/// ```swift
/// struct WeightForm: View {
///     @State private var viewModel = FormFieldViewModel<Measurement<UnitMass>?>(
///         value: nil,
///         title: "Weight:",
///         placeholder: "Enter weight"
///     )
///
///     var body: some View {
///         Form {
///             FormOptionalValueUnitField(
///                 viewModel,
///                 defaultValue: Measurement(value: 0, unit: .kilograms)
///             )
///         }
///     }
/// }
/// ```
///
/// ### Temperature Field with Menu Style Picker
///
/// ```swift
/// @QuickForm(Recipe.self)
/// class RecipeFormModel: Validatable {
///     @PropertyEditor(keyPath: \Recipe.bakingTemperature)
///     var temperature = FormFieldViewModel<Measurement<UnitTemperature>?>(
///         value: nil,
///         title: "Baking Temperature:",
///         placeholder: "Enter temperature",
///         validation: .of(.required("Temperature is required"))
///     )
/// }
///
/// struct RecipeEditView: View {
///     @Bindable var model: RecipeFormModel
///
///     var body: some View {
///         Form {
///             FormOptionalValueUnitField(
///                 model.temperature,
///                 defaultValue: Measurement(value: 180, unit: .celsius),
///                 pickerStyle: .menu
///             )
///         }
///     }
/// }
/// ```
///
/// ### Distance Field with Segmented Picker Style
///
/// ```swift
/// // When you have only a few common units to choose from
/// FormOptionalValueUnitField(
///     distanceViewModel,
///     defaultValue: Measurement(value: 0, unit: .kilometers),
///     pickerStyle: .segmented
/// )
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``Unit``, ``AllValues``, ``Measurement``
public struct FormOptionalValueUnitField<T: Unit, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>?>
    @FocusState private var isFocused: Bool
    @State private var hasError: Bool
    private let pickerStyle: S
    private let defaultValue: Measurement<T>

    /// The body of the form field view.
    ///
    /// This view consists of:
    /// - A title label (when provided)
    /// - A numeric text field for the measurement value
    /// - A picker for selecting the unit of measure
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: viewModel.validationResult) { _, newValue in
            withAnimation {
                hasError = newValue != .success
            }
        }
    }

    /// Initializes a new `FormOptionalValueUnitField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this optional measurement field.
    ///   - defaultValue: The default measurement to use when the value is `nil`. This provides both
    ///     a default value and unit.
    ///   - pickerStyle: The style to apply to the unit picker. Defaults to `.menu`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Weight field with kilograms as default unit
    /// FormOptionalValueUnitField(
    ///     weightViewModel,
    ///     defaultValue: Measurement(value: 0, unit: .kilograms)
    /// )
    ///
    /// // Length field with custom picker style
    /// FormOptionalValueUnitField(
    ///     lengthViewModel,
    ///     defaultValue: Measurement(value: 0, unit: .meters),
    ///     pickerStyle: .wheel
    /// )
    /// ```
    public init(
        _ viewModel: FormFieldViewModel<Measurement<T>?>,
        defaultValue: Measurement<T>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.defaultValue = defaultValue
        self.pickerStyle = pickerStyle
        hasError = viewModel.errorMessage != nil
        isFocused = false
    }
}

#Preview("Basic") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.none,
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormOptionalValueUnitField(viewModel, defaultValue: Measurement<UnitMass>(value: 34, unit: .kilograms))
    }
}

#Preview("With Value") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.some(.init(value: 75, unit: .kilograms)),
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormOptionalValueUnitField(viewModel, defaultValue: Measurement<UnitMass>(value: 0, unit: .kilograms))
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.some(.init(value: 75, unit: .kilograms)),
        title: "Weight",
        isReadOnly: true
    )

    Form {
        FormOptionalValueUnitField(viewModel, defaultValue: Measurement<UnitMass>(value: 0, unit: .kilograms))
    }
}

extension UnitTemperature: @retroactive Identifiable {}
extension UnitTemperature: AllValues {
    public static var allCases: [UnitTemperature] = [
        .celsius,
        .fahrenheit,
        .kelvin
    ]
}

#Preview("Temperature") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitTemperature>?.some(.init(value: 180, unit: .celsius)),
        title: "Baking Temperature",
        placeholder: "Enter temperature"
    )

    Form {
        FormOptionalValueUnitField(viewModel, defaultValue: Measurement<UnitTemperature>(value: 0, unit: .celsius))
    }
}
