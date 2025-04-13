// FormValueDimensionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 20:51 GMT.

import Foundation
import SwiftUI

/// A protocol that defines a type with all possible cases.
///
/// This protocol is used to constrain the unit type in ``FormValueDimensionField`` to ensure
/// that all possible units can be displayed in the picker. Types conforming to this protocol
/// must provide a collection of all available cases through the `allCases` static property.
///
/// Swift's `Dimension` types like `UnitMass`, `UnitLength`, etc. can be extended to conform
/// to this protocol by providing their available units.
///
/// ## Example
///
/// ```swift
/// extension UnitLength: AllValues {
///     public static var allCases: [UnitLength] { [
///         .meters, .kilometers, .feet, .inches, .yards, .miles
///     ] }
/// }
/// ```
public protocol AllValues {
    associatedtype Unit: Identifiable
    static var allCases: [Unit] { get }
}

/// A SwiftUI view that represents a field for inputting a value with an associated unit of measurement.
///
/// `FormValueDimensionField` is designed to work with ``FormFieldViewModel<Measurement<T>>`` to provide
/// an interface for inputting a numeric value along with a selectable unit of measurement.
/// This is particularly useful for fields where both a quantity and its unit need to be specified,
/// such as weight, length, temperature, or any other measurable quantity.
///
/// When the user changes the unit, the field automatically converts the current value to the
/// equivalent value in the newly selected unit, preserving the actual measurement quantity.
///
/// ## Features
/// - Displays a text field for the numeric value alongside a picker for the unit
/// - Supports any `Dimension` type that conforms to ``AllValues``
/// - Automatically converts the value when the unit is changed
/// - Supports customizable picker styles for the unit selection
/// - Can be set to read-only mode
///
/// ## Examples
///
/// ### Basic Mass Measurement
///
/// ```swift
/// struct ProductForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: Measurement(value: 0.5, unit: UnitMass.kilograms),
///         title: "Weight:"
///     )
///
///     var body: some View {
///         Form {
///             FormValueDimensionField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### Length Measurement with Custom Picker Style
///
/// ```swift
/// struct DimensionsForm: View {
///     @State private var lengthViewModel = FormFieldViewModel(
///         value: Measurement(value: 150, unit: UnitLength.centimeters),
///         title: "Length:",
///         placeholder: "Enter length"
///     )
///
///     var body: some View {
///         Form {
///             FormValueDimensionField(lengthViewModel, pickerStyle: .segmented)
///         }
///     }
/// }
/// ```
///
/// ### With Form Model Integration and Validation
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
///
///     @PropertyEditor(keyPath: \Product.dimensions.height)
///     var height = FormFieldViewModel(
///         value: Measurement(value: 0, unit: UnitLength.centimeters),
///         title: "Height:",
///         validation: .of(.greaterThan(0, "Height must be greater than 0"))
///     )
/// }
///
/// struct ProductEditView: View {
///     @Bindable var model: ProductFormModel
///
///     var body: some View {
///         Form {
///             Section("Product Specifications") {
///                 FormValueDimensionField(model.weight)
///                     .validationState(model.weight.validationResult)
///
///                 FormValueDimensionField(model.height)
///                     .validationState(model.height.validationResult)
///             }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``Measurement``, ``AllValues``
public struct FormValueDimensionField<T: Dimension, S: PickerStyle>: View where T: AllValues, T.Unit == T {
    @Bindable private var viewModel: FormFieldViewModel<Measurement<T>>
    @FocusState private var isFocused: Bool
    private let pickerStyle: S

    /// The body of the `FormValueDimensionField` view.
    ///
    /// This view consists of:
    /// - A title label
    /// - A text field for entering the numeric value
    /// - A picker for selecting the unit of measurement
    ///
    /// When the unit is changed, the value is automatically converted to maintain
    /// the same measurement quantity.
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

    /// Initializes a new `FormValueDimensionField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this field.
    ///     The view model must have a value of type `Measurement<T>` where `T` is a
    ///     `Dimension` type that conforms to ``AllValues``.
    ///   - pickerStyle: The style to apply to the unit picker. Defaults to `.menu`.
    ///     Common values include:
    ///     - `.menu`: A dropdown menu (default and space-efficient)
    ///     - `.segmented`: A segmented control (good for a small number of units)
    ///     - `.wheel`: A wheel picker (iOS, good for scrolling through many options)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Weight with menu picker (default)
    /// FormValueDimensionField(weightViewModel)
    ///
    /// // Length with segmented picker
    /// FormValueDimensionField(
    ///     lengthViewModel,
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

/// Extension to make UnitMass identifiable for use in ForEach.
extension UnitMass: @retroactive Identifiable {}

/// Extension to provide all available mass units for UnitMass.
extension UnitMass: AllValues {
    /// Returns all available mass units for use in pickers.
    ///
    /// This list includes both metric and imperial units to support various measurement systems.
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

// The following extensions can be added to support other measurement types

// /// Extension to make UnitLength identifiable for use in ForEach.
// extension UnitLength: @retroactive Identifiable {}
//
// /// Extension to provide commonly used length units for UnitLength.
// extension UnitLength: AllValues {
//     public static var allCases: [UnitLength] { [
//         .meters,
//         .kilometers,
//         .centimeters,
//         .millimeters,
//         .inches,
//         .feet,
//         .yards,
//         .miles
//     ] }
// }

#Preview("Mass") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 34, unit: .kilograms),
        title: "Weight",
        isReadOnly: false
    )

    Form {
        FormValueDimensionField(viewModel)
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 34, unit: .kilograms),
        title: "Weight",
        isReadOnly: true
    )

    Form {
        FormValueDimensionField(viewModel)
    }
}
