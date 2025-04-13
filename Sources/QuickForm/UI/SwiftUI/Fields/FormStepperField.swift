// FormStepperField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 19:21 GMT.

import SwiftUI

/// A SwiftUI view that represents a stepper field in a form.
///
/// `FormStepperField` is designed to work with ``FormFieldViewModel`` to provide
/// an interface for incrementally adjusting numeric values. This view is particularly useful
/// for entering bounded numeric values where precision input is needed, such as quantities,
/// counts, or numeric settings.
///
/// ## Features
/// - Displays a stepper with a label showing the current value
/// - Supports optional range constraints to limit minimum and maximum values
/// - Allows customizing the step increment/decrement value
/// - Automatically binds to a numeric value in the view model
/// - Supports any `Strideable` value type (Int, Double, etc.)
///
/// ## Examples
///
/// ### Basic Integer Stepper
///
/// ```swift
/// struct QuantityForm: View {
///     @State private var quantityModel = FormFieldViewModel(
///         value: 1,
///         title: "Quantity:",
///         validation: .of(.range(1...10, "Quantity must be between 1 and 10"))
///     )
///
///     var body: some View {
///         Form {
///             FormStepperField(viewModel: quantityModel, range: 1...10, step: 1)
///         }
///     }
/// }
/// ```
///
/// ### Double Value with Custom Step
///
/// ```swift
/// struct TemperatureForm: View {
///     @State private var tempModel = FormFieldViewModel(
///         value: 22.5,
///         title: "Temperature (°C):"
///     )
///
///     var body: some View {
///         Form {
///             FormStepperField(viewModel: tempModel, range: 18.0...30.0, step: 0.5)
///         }
///     }
/// }
/// ```
///
/// ### Combining with Other Form Fields
///
/// ```swift
/// struct ProductForm: View {
///     @Bindable var model: ProductFormModel
///
///     var body: some View {
///         Form {
///             Section("Product Details") {
///                 FormTextField(model.name)
///
///                 FormStepperField(viewModel: model.quantity, range: 1...100, step: 1)
///
///                 FormToggleField(model.isAvailable)
///             }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormTextField``, ``FormToggleField``
public struct FormStepperField<Value: Strideable>: View {
    @Bindable private var viewModel: FormFieldViewModel<Value>
    private let range: ClosedRange<Value>?
    private let step: Value.Stride

    /// The body of the stepper field view.
    ///
    /// This view creates a SwiftUI `Stepper` bound to the view model's value.
    /// If a range is provided, the stepper's values are constrained to that range.
    /// The stepper's label displays the field title and current value.
    public var body: some View {
        if let range {
            Stepper(
                value: $viewModel.value,
                in: range,
                step: step,
                label: label
            )
        } else {
            Stepper(
                value: $viewModel.value,
                step: step,
                label: label
            )
        }
    }

    /// Initializes a new stepper field for the given view model.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this stepper field.
    ///   - range: An optional range that constrains the values of the stepper. When `nil`,
    ///     the stepper has no minimum or maximum limits.
    ///   - step: The amount to increment or decrement the value when the user taps the stepper buttons.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic integer stepper with range constraints
    /// FormStepperField(
    ///     viewModel: countViewModel,
    ///     range: 0...10,
    ///     step: 1
    /// )
    ///
    /// // Float stepper with half-step increments
    /// FormStepperField(
    ///     viewModel: ratingViewModel,
    ///     range: 1.0...5.0,
    ///     step: 0.5
    /// )
    /// ```
    public init(viewModel: FormFieldViewModel<Value>, range: ClosedRange<Value>? = nil, step: Value.Stride) {
        self.viewModel = viewModel
        self.range = range
        self.step = step
    }

    /// Creates the label view for the stepper.
    ///
    /// This function returns a view that displays the field title and the current value.
    private func label() -> some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            Text("\(viewModel.value)")
        }
    }
}

#Preview("Integer Stepper") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Int(0),
        title: "Count:"
    )

    Form {
        FormStepperField(viewModel: viewModel, step: 1)
    }
}

#Preview("Bounded Range") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Int(5),
        title: "Quantity:"
    )

    Form {
        FormStepperField(viewModel: viewModel, range: 1 ... 10, step: 1)
    }
}

#Preview("Double Value") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: 37.0,
        title: "Temperature (°C):"
    )

    Form {
        FormStepperField(viewModel: viewModel, range: 35.0 ... 43.0, step: 0.1)
    }
}
